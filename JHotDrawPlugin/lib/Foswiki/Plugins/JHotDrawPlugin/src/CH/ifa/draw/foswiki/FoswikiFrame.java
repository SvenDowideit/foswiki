/*
 * @(#)JHotDraw.java 5.1
 * Copyright 2000 by Peter Thoeny, Peter@Thoeny.com.
 * It is hereby granted that this software can be used, copied, 
 * modified, and distributed without fee provided that this 
 * copyright notice appears in all copies.
 * Portions Copyright (C) 2001 Motorola - All Rights Reserved
 * Copyright (C) 2008 Foswiki Contributors
 */
package CH.ifa.draw.foswiki;

import java.awt.Label;
import java.awt.Color;
import java.awt.Font;
import java.awt.Panel;
import java.awt.Button;
import java.awt.MenuBar;
import java.awt.GridLayout;
import java.awt.Cursor;
import java.awt.Dimension;
import java.awt.Rectangle;
import java.awt.Image;
import java.awt.Graphics;
import java.awt.Frame;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;

import java.awt.image.FilteredImageSource;

import java.io.ByteArrayOutputStream;
import java.io.IOException;

import Acme.JPM.Encoders.GifEncoder;

import com.eteks.filter.Web216ColorsFilter;

import CH.ifa.draw.appframe.Application;
import CH.ifa.draw.appframe.DrawFrame;
import CH.ifa.draw.framework.Tool;
import CH.ifa.draw.framework.Figure;
import CH.ifa.draw.framework.FigureEnumeration;
import CH.ifa.draw.standard.AlignCommand;
import CH.ifa.draw.standard.DeleteCommand;
import CH.ifa.draw.standard.CutCommand;
import CH.ifa.draw.standard.CopyCommand;
import CH.ifa.draw.standard.PasteCommand;
import CH.ifa.draw.standard.DuplicateCommand;
import CH.ifa.draw.standard.SendToBackCommand;
import CH.ifa.draw.standard.BringToFrontCommand;
import CH.ifa.draw.standard.ToggleGuidesCommand;
import CH.ifa.draw.standard.ChangeAttributeCommand;
import CH.ifa.draw.standard.CreationTool;
import CH.ifa.draw.standard.ConnectionTool;

import CH.ifa.draw.figures.GroupCommand;
import CH.ifa.draw.figures.UngroupCommand;
import CH.ifa.draw.figures.PolyLineFigure;
import CH.ifa.draw.figures.TextTool;
import CH.ifa.draw.figures.ConnectedTextTool;
import CH.ifa.draw.figures.TextFigure;
import CH.ifa.draw.figures.RectangleFigure;
import CH.ifa.draw.figures.RoundRectangleFigure;
import CH.ifa.draw.figures.EllipseFigure;
import CH.ifa.draw.figures.LineFigure;
import CH.ifa.draw.figures.ElbowConnection;
import CH.ifa.draw.figures.LineConnection;
import CH.ifa.draw.figures.ScribbleTool;
import CH.ifa.draw.figures.URLTool;
import CH.ifa.draw.figures.BorderTool;

import CH.ifa.draw.util.CommandMenu;
import CH.ifa.draw.util.ColorMap;
import CH.ifa.draw.util.CommandButton;
import CH.ifa.draw.util.Command;
import CH.ifa.draw.util.StorableOutput;
import CH.ifa.draw.contrib.PolygonTool;

public class FoswikiFrame extends DrawFrame {

    private Label fStatusLabel;
    private String drawingName = null;
    
    public FoswikiFrame(Application applet, String colors) {
        super("JHotDraw", applet);

        this.view().setBackground(Color.white);

        ColorMap.reset();
        if (colors != null) {
            // parse the colors string and add colors to the static color map
            do {
                String thisColor;
                int split = colors.indexOf(',');
                if (split == -1) {
                    thisColor = colors;
                    colors = "";
                } else {
                    thisColor = colors.substring(0, split);
                    colors = colors.substring(split + 1);
                }
                split = thisColor.indexOf('=');
                if (split == -1) {
                    continue;
                }
                String name = thisColor.substring(0, split).trim();
                if (split < thisColor.length() - 1 &&
                        thisColor.charAt(split + 1) == '#') {
                    split++;
                }
                String value = thisColor.substring(split + 1).trim();
                try {
                    int i = Integer.valueOf(value, 16).intValue();
                    ColorMap.getColorMap().addColor(name, new Color(i));
                } catch (NumberFormatException nfe) {
                    nfe.printStackTrace();
                }
            } while (colors.length() > 0);
        }
        drawingName = applet.getParameter("drawingname");
        if (drawingName == null) {
            drawingName = "untitled";
        }
        String url = applet.getParameter("drawingurl") + "/" +
                drawingName + ".draw";
        loadDrawing(url);

        this.addWindowListener(closeSpotter);
    }

    
    private WindowAdapter closeSpotter = new WindowAdapter() {
        public void windowClosing(WindowEvent e) {
            if (ExitVetoDialog.ok((Frame)e.getSource()))
                getApplication().exit();
        }
    };
    
    protected void populateMenuBar(MenuBar menuBar) {
        menuBar.add(createDrawingMenu());
        menuBar.add(createEditMenu());
        menuBar.add(createSelectionMenu());
        menuBar.add(createFillMenu());
        menuBar.add(createLineMenu());
        menuBar.add(createTextMenu());
        setMenuBar(menuBar);
    }

    protected CommandMenu createDrawingMenu() {
        CommandMenu menu = new CommandMenu("Drawing");

        menu.add(new NewDrawingCommand(this));
        menu.add(new ReloadDrawingCommand(this));
        menu.add(new SaveCommand(this));
        menu.add(new SaveAsCommand(this));
        menu.add(new ExitCommand(this));

        return menu;
    }

    protected CommandMenu createEditMenu() {
        CommandMenu menu = new CommandMenu("Edit");

        menu.add(new DeleteCommand("Delete", view()));
        menu.add(new CutCommand("Cut", view()));
        menu.add(new CopyCommand("Copy", view()));
        menu.add(new PasteCommand("Paste", view()));
        menu.add(new ToggleGuidesCommand("Toggle guides", view()));

        return menu;
    }

    protected CommandMenu createSelectionMenu() {
        CommandMenu menu = new CommandMenu("Selection");

        menu.add(new DuplicateCommand("Duplicate", view()));
        menu.add(new GroupCommand("Group", view()));
        menu.add(new UngroupCommand("Ungroup", view()));
        menu.add(new SendToBackCommand("Send to Back", view()));
        menu.add(new BringToFrontCommand("Bring to Front", view()));

        CommandMenu align = new CommandMenu("Align");
        align.add(new AlignCommand("Lefts", view(), AlignCommand.LEFTS));
        align.add(new AlignCommand("Centres", view(), AlignCommand.CENTERS));
        align.add(new AlignCommand("Rights", view(), AlignCommand.RIGHTS));
        align.add(new AlignCommand("Tops", view(), AlignCommand.TOPS));
        align.add(new AlignCommand("Middles", view(), AlignCommand.MIDDLES));
        align.add(new AlignCommand("Bottoms", view(), AlignCommand.BOTTOMS));
        menu.add(align);

        return menu;
    }

    protected CommandMenu createFillMenu() {
        CommandMenu menu = new CommandMenu("Fill");
        menu.add(createColorMenu("FillColor"));
        return menu;
    }

    protected CommandMenu createLineMenu() {
        CommandMenu menu = new CommandMenu("Line");

        menu.add(createColorMenu("FrameColor"));

        CommandMenu arrowStyle = new CommandMenu("Arrows");
        arrowStyle.add(
                new ChangeAttributeCommand(
                "none", "ArrowMode",
                new Integer(PolyLineFigure.ARROW_TIP_NONE), view()));
        arrowStyle.add(
                new ChangeAttributeCommand(
                "at Start", "ArrowMode",
                new Integer(PolyLineFigure.ARROW_TIP_START), view()));
        arrowStyle.add(
                new ChangeAttributeCommand(
                "at End", "ArrowMode",
                new Integer(PolyLineFigure.ARROW_TIP_END), view()));
        arrowStyle.add(
                new ChangeAttributeCommand(
                "at Both ends", "ArrowMode",
                new Integer(PolyLineFigure.ARROW_TIP_BOTH), view()));
        menu.add(arrowStyle);

        return menu;
    }

    protected CommandMenu createTextMenu() {
        CommandMenu menu = new CommandMenu("Text");

        menu.add(createFontMenu());
        menu.add(createColorMenu("TextColor"));

        CommandMenu style = new CommandMenu("Style");
        style.add(new ChangeAttributeCommand(
                "Plain", "FontStyle", new Integer(Font.PLAIN), view()));
        style.add(new ChangeAttributeCommand(
                "Italic", "FontStyle", new Integer(Font.ITALIC), view()));
        style.add(new ChangeAttributeCommand(
                "Bold", "FontStyle", new Integer(Font.BOLD), view()));
        menu.add(style);

        CommandMenu align = new CommandMenu("Align");
        align.add(new ChangeAttributeCommand(
                "Left", "TextAlign", "Left", view()));
        align.add(new ChangeAttributeCommand(
                "Centre", "TextAlign", "Centre", view()));
        align.add(new ChangeAttributeCommand(
                "Right", "TextAlign", "Right", view()));
        menu.add(align);

        return menu;
    }

    //-- DrawFrame overrides -----------------------------------------
    protected void populateWestPanel(Panel palette) {
        // get the default selection tool
        super.populateWestPanel(palette);

        Tool tool = new TextTool(view(), new TextFigure());
        palette.add(createToolButton(IMAGES + "TEXT", "Text Tool", tool));

        tool = new ConnectedTextTool(view(), new TextFigure());
        palette.add(createToolButton(IMAGES + "ATEXT", "Connected Text Tool", tool));

        tool = new CreationTool(view(), new RectangleFigure());
        palette.add(createToolButton(IMAGES + "RECT", "Rectangle Tool", tool));

        tool = new CreationTool(view(), new RoundRectangleFigure());
        palette.add(createToolButton(IMAGES + "RRECT", "Round Rectangle Tool", tool));

        tool = new CreationTool(view(), new EllipseFigure());
        palette.add(createToolButton(IMAGES + "ELLIPSE", "Ellipse Tool", tool));

        tool = new CreationTool(view(), new LineFigure());
        palette.add(createToolButton(IMAGES + "LINE", "Line Tool", tool));

        tool = new ConnectionTool(view(), new LineConnection());
        palette.add(createToolButton(IMAGES + "CONN", "Connection Tool", tool));

        tool = new ConnectionTool(view(), new ElbowConnection());
        palette.add(createToolButton(IMAGES + "OCONN", "Elbow Connection Tool", tool));

        tool = new ScribbleTool(view());
        palette.add(createToolButton(IMAGES + "SCRIBBL", "Scribble Tool", tool));

        tool = new PolygonTool(view());
        palette.add(createToolButton(IMAGES + "POLYGON", "Polygon Tool", tool));

        tool = new BorderTool(view());
        palette.add(createToolButton(IMAGES + "BORDDEC", "Border Tool", tool));

        tool = new URLTool(view(), new RectangleFigure());
        palette.add(createToolButton(IMAGES + "URL", "URL Tool", tool));
    }

    protected Panel createSouthPanel() {
        Panel split = new Panel();
        split.setLayout(new GridLayout(2, 1));
        return split;
    }

    protected void populateSouthPanel(Panel panel) {
        Panel buttons = new Panel();
        Button button;

        button = new CommandButton(new DeleteCommand("Delete", view()));
        buttons.add(button);

        button = new CommandButton(new DuplicateCommand("Duplicate", view()));
        buttons.add(button);

        button = new CommandButton(new GroupCommand("Group", view()));
        buttons.add(button);

        button = new CommandButton(new UngroupCommand("Ungroup", view()));
        buttons.add(button);

        button = new CommandButton(new BringToFrontCommand("Bring To Front", view()));
        buttons.add(button);

        button = new CommandButton(new SendToBackCommand("Send To Back", view()));
        buttons.add(button);

        button = new Button("Help");
        button.addActionListener(
                new ActionListener() {

                    public void actionPerformed(ActionEvent event) {
                        showHelp();
                    }
                });
        buttons.add(button);
        panel.add(buttons);
        fStatusLabel = new Label("Status");
        panel.add(fStatusLabel);
    }

    public void showStatus(String s) {
        if (fStatusLabel != null) {
            fStatusLabel.setText(s);
        } else {
            getApplication().showStatus(s);
        }
    }

    /**
     * Workaround to get it work without update button
     */
    protected void setSimpleDisplayUpdate() {
    }

    protected void setBufferedDisplayUpdate() {
    }

    //-- actions -----------------------------------------
    protected void showHelp() {
        // gets help file path
        String helpPath =
                getApplication().getParameter("helpurl");
        getApplication().popupFrame(helpPath, "Help");
    }

    class NewDrawingCommand extends Command {

        FoswikiFrame frame;

        public NewDrawingCommand(FoswikiFrame frm) {
            super("Clear");
            frame = frm;
        }

        public void execute() {
            frame.doLoadDrawing(null);
        }
    }

    class ReloadDrawingCommand extends Command {

        FoswikiFrame frame;

        public ReloadDrawingCommand(FoswikiFrame frm) {
            super("Revert");
            frame = frm;
        }

        public void execute() {
            frame.doLoadDrawing(drawingName);
        }
    }

    class SaveCommand extends Command {

        FoswikiFrame frame;

        public SaveCommand(FoswikiFrame frm) {
            super("Save");
            frame = frm;
        }

        public void execute() {
            save(drawingName);
        }
    }

    class SaveAsCommand extends Command {

        FoswikiFrame frame;

        public SaveAsCommand(FoswikiFrame frm) {
            super("Save As");
            frame = frm;
        }

        public void execute() {
            String newName = SaveAsDialog.prompt(frame, drawingName);
            if (newName != null) {
                drawingName = newName;
                save(drawingName);
            }
        }
    }

    class ExitCommand extends Command {

        FoswikiFrame frame;

        public ExitCommand(FoswikiFrame frm) {
            super("Exit");
            frame = frm;
        }

        public void execute() {
            if (ExitVetoDialog.ok(frame))
                getApplication().exit();
        }
    }

    public void doLoadDrawing(String name) {
        drawingName = name;
        String url = null;
        if (name != null) {
            url = getApplication().getParameter("drawingurl") + "/" +
                drawingName + ".draw";
        }
        loadDrawing(url);
        view().setBackground(Color.white);
    }

    public void save(String drawingName) {
        boolean savedDraw, savedSvg, savedGif, savedMap;
        savedDraw = savedSvg = savedGif = savedMap = false;

        // set wait cursor
        setCursor(new Cursor(Cursor.WAIT_CURSOR));

        Dimension d = new Dimension(0, 0); // not this.view().getSize();
        FigureEnumeration k = drawing().figuresReverse();
        while (k.hasMoreElements()) {
            Figure figure = k.nextFigure();
            Rectangle r = figure.displayBox();
            if (r.x + r.width > d.width) {
                d.setSize(r.x + r.width, d.height);
            }
            if (r.y + r.height > d.height) {
                d.setSize(d.width, r.y + r.height);
            }
        }

        // add border size
        int iBorder = 10;
        String sBorder = getApplication().getParameter("bordersize");
        if (sBorder != null) {
            iBorder = Integer.valueOf(sBorder).intValue();
            if (iBorder < 0) {
                iBorder = 0;
            }
        }

        showStatus("Saving " + drawingName);
        Application app = getApplication();
        app.pushSaveParam(drawingName);
        ByteArrayOutputStream out = new ByteArrayOutputStream();
        StorableOutput output = new StorableOutput(out);
        // drawing() (class DrawFrame) returns the Drawing element
        // Drawing is a StandardDrawing (extends Drawing
        // and implements CompositeFigures)
        output.writeStorable(drawing());
        output.close();
        app.pushSaveParam("draw");
        app.pushSaveParam(out.toString());

        String map = drawing().getMap();
        if (map.length() > 0) {
            // enclose the map and add editable border. Note that the
            // edit border is added LAST so the earlier AREAs take
            // precedence.
            String area = "<area shape=\"rect\" coords=\"";
            String link = "\" href=\"%FOSWIKIDRAW%\" " +
                    "alt=\"%EDITTEXT%\" title=\"%EDITTEXT%\" />";
            map = "<map name=\"%MAPNAME%\">" + map +
                    area +
                    "0,0," + (d.width + iBorder) + "," + (iBorder / 2) +
                    link +
                    area +
                    "0,0," + iBorder / 2 + "," + (d.height + iBorder) +
                    link +
                    area +
                    (d.width + iBorder / 2) + ",0," + (d.width + iBorder) + "," +
                    (d.height + iBorder) +
                    link +
                    area +
                    "0," + (d.height + iBorder / 2) + "," +
                    (d.width + iBorder) + "," + (d.height + iBorder) +
                    link +
                    "</map>";
        } else {
            // erase any previous map file
            map = "";
        }
        app.pushSaveParam("map");
        app.pushSaveParam(map);

        /*
        showStatus("Saving " + drawingName + ".svg");
        // create the svg data
        String outsvg = SvgSaver.convertSVG(out.toString());
        // now upload *.svg file
        if (bPostEnabled)
        savedSvg = app.post(drawingName + ".svg", "image/svg",
        outsvg, "JHotDraw SVG file");
         */

        // clear the selection so it doesn't appear in the GIF
        view().clearSelection();

        final Image oImgBuffer =
                this.view().createImage(d.width + iBorder, d.height + iBorder);
        app.pushSaveParam("gif");
        try {
            app.pushSaveParam(Base64.encode(convertToGif(oImgBuffer)));
        } catch (IOException ioe) {
            System.out.println("Failed to convert GIF: " + ioe);
            showStatus("Failed to convert GIF");
        }
        this.setCursor(new Cursor(Cursor.DEFAULT_CURSOR));

        app.commitSaves();
        showStatus("Saved " + drawingName);
    }

    /** debugging messages */
    static void debug(String msg) {
        System.err.println("JHotDraw:" + msg);
    }

    /**
     * convert Image to GIF-encoded data, reducing the number of colors
     * if needed. Added by Bertrand Delacretaz
     */
    private char[] convertToGif(Image oImgBuffer) throws IOException {
        debug("converting data to GIF...");
        Graphics oGrf = oImgBuffer.getGraphics();
        this.view().enableGuides(false);
        this.view().drawAll(oGrf);

        // test gif image:
        //TestFrame tf = new TestFrame( "tt2: " + oImgBuffer.toString() ); 
        //tf.setSize(new Dimension(d.width+30, d.height+30));
        //tf.setImage(oImgBuffer);
        //tf.show();

        ByteArrayOutputStream oOut = null;

        try {
            oOut = new ByteArrayOutputStream();
            new GifEncoder(oImgBuffer, oOut).encode();
        } catch (IOException ioe) {
            // GifEncoder throws IOException when GIF contains too many colors
            // if this happens, filter image to reduce number of colors
            debug("GIF uses too many colors, reducing to 216 colors...");
            final FilteredImageSource filter = new FilteredImageSource(oImgBuffer.getSource(), new Web216ColorsFilter());
            oOut = new ByteArrayOutputStream();
            new GifEncoder(filter, oOut).encode();
            debug("Color reduction successful.");
        }
        byte[] aByte = oOut.toByteArray();
        int size = oOut.size();
        char[] aChar = new char[size];
        for (int i = 0; i < size; i++) {
            aChar[i] = (char) aByte[i];
        }
        debug("conversion to GIF successful.");
        return aChar;
    }
}
