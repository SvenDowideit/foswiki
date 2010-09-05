(function($) {
  /***************************************************************************
   * initializes the insert attachment
   */
  $.natedit.initInsertAttachment = function(nateditor) {
    var $inserter = $("#natEditInsertAttachment");
    $inserter.find("label").show();
    $inserter.find(".selected").removeClass("selected");

    $inserter.find(".baseweb").each(function() {
      var val = $(this).val();
      if (!val) {
        $(this).val(foswiki.web);
      }
    });
    
    $inserter.find(".basetopic").each(function() {
      var val = $(this).val();
      if (!val) {
        $(this).val(foswiki.topic);
      }
    });

    $inserter.find("#natEditInsertAttachmentFile").val("");

    $("#natEditInsertAttachmentWeb").autocomplete(
      foswiki.scriptUrlPath+"/view/"+foswiki.systemWebName+"/JQueryAjaxHelper?section=web&contenttype=text/plain&skin=text", {
        matchCase: true
    });

    $("#natEditInsertAttachmentTopic").autocomplete(
      foswiki.scriptUrlPath+"/view/"+foswiki.systemWebName+"/JQueryAjaxHelper?section=topic&contenttype=text/plain&skin=text", {
        matchCase: true,
	extraParams: {
	  baseweb: function() { 
	    return jQuery('#natEditInsertAttachmentWeb').val();
	  }
	}
      }
    ).keypress(function(e) {
      if (e.which == 13) {
        $.natedit.loadAttachments(nateditor);
      }
    });

    $inserter.find("#natEditInsertAttachmentFile").keyup(function(e) {
      var fileName = $(this).val();
      var foundFileName;
      var $foundLabel;
      var count = 0;
      if (fileName) {
        $inserter.find("label").each(function() {
          var $this = $(this);
          var opts = $this.metadata();
          if (opts.fileName.indexOf(fileName) != 0) {
            $this.hide();
          } else {
            $this.show();
            count++;
            foundFileName = opts.fileName;
            $foundLabel = $this;
          }
        });
      } else {
        $inserter.find("label").show();
        $inserter.find(".selected").removeClass("selected");
      }
      if (count == 1 && e.which == 13) {
        $inserter.find(".selected").removeClass("selected");
        $foundLabel.addClass("selected");
        $("#natEditInsertAttachmentFile").val(foundFileName);
      }
    });

    // bind to uploader events
    $inserter.find(".jqUploader").bind("success.uploader", function() {
      $.natedit.loadAttachments(nateditor, true);
    });
  
    $.natedit.loadAttachments(nateditor);
  };

  /***************************************************************************
   * load attachment preview 
   */
  $.natedit.loadAttachments = function(nateditor, force) {
    var web = $("#natEditInsertAttachmentWeb").val();
    var topic = $("#natEditInsertAttachmentTopic").val();
    if (!web && !topic) {
      return
    }
    if (web == nateditor._prevWeb && topic == nateditor._prevTopic && !force) {
      return;
    }
    nateditor._prevWeb = web;
    nateditor._prevTopic = topic;
    $("#natEditInsertAttachments").empty().append("<span class='jqAjaxLoader'>&nbsp;</span>").css({overflow:'auto'});
    $("#natEditInsertAttachments").load(
      foswiki.scriptUrlPath+"/rest/RenderPlugin/template?refresh=dbcache;name=editdialog;expand=insertattachment::loadattachments;baseweb="+web+";basetopic="+topic,
      function() {
        //var found = 0;
	$("#natEditInsertAttachment label").each(function() {
          //found++;
          var $this = $(this);
	  var opts = $this.metadata();
	  if (opts.fileName.match(/jpe?g|gif|png|bmp/i)) {
	    var src = opts.url;
	    if (foswiki.ImagePluginEnabled) {
	      src = foswiki.scriptUrlPath+"/rest/ImagePlugin/resize?"+
		"topic="+opts.web+"."+opts.topic+";"+
		"file="+opts.fileName+";"+
		"width=70";
	      $this.find("img").attr('src', src);
	    }
	  }
          $this.click(function() {
            $("#natEditInsertAttachment .selected").removeClass("selected");
            $this.addClass("selected");
            $("#natEditInsertAttachmentFile").val(opts.fileName);
          });
        });
        /*
        if (!found) {
          $("#natEditInsertAttachments").slideUp(300, function() {
            $(window).trigger("resize");
          });
        } else {
          $("#natEditInsertAttachments").slideDown(300, function() {
            $(window).trigger("resize");
          });
        }
        */
      });
  };

  /***************************************************************************
   * handles the submit action for the insert attachment dialog
   */
  $.natedit.handleInsertAttachment = function(nateditor) {
    var markup;
    var web = $("#natEditInsertAttachmentWeb").val();
    var topic = $("#natEditInsertAttachmentTopic").val();
    var fileName = $("#natEditInsertAttachmentFile").val();

    if (!fileName) {
      return;
    }

    var linktext = $("#natEditInsertAttachmentText").val();
    var url = "%PUBURL%/"+web+"/"+topic+"/"+fileName;
    if (web == foswiki.web && topic == foswiki.topic) {
      url = "%ATTACHURL%/"+fileName;
    }

    if (foswiki.ImagePluginEnabled && fileName.match(/jpe?g|gif|png|bmp/i) && !linktext) {
      if (web == foswiki.web && topic == foswiki.topic) {
        markup = '%IMAGE{"'+fileName+'"';
      } else {
        markup = '%IMAGE{"'+web+"/"+topic+"/"+fileName+'"';
      }
      markup += "}%";
    } else {
      if (linktext) {
        markup = "[["+url+"]["+linktext+"]]";
      } else {
        markup = "[["+url+"]]";
      }
    }
    nateditor.remove();
    nateditor.insertTag(['', markup, '']);
  };

})(jQuery);
