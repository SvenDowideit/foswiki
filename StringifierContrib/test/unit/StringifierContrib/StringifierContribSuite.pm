package StringifierContribSuite;
use Unit::TestSuite;
our @ISA = qw( Unit::TestSuite );

sub include_tests {
    qw(
      StringifyBaseTest Doc_antiwordTests Doc_wvTests DocxTests Doc_abiwordTests
      XlsTests PdfTests TxtTests HtmlTests PptTests PptxTests XlsxTests OdtTests
    );
}

1;
