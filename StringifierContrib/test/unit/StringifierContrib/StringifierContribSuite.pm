package StringifierContribSuite;
use Unit::TestSuite;
our @ISA = qw( Unit::TestSuite );

sub include_tests {
  qw(
    StringifyBaseTest Doc_antiwordTests Doc_wvTests Doc_abiwordTests DocxTests
    PdfTests TxtTests HtmlTests PptTests PptxTests XlsxTests OdtTests XlsTests
  );
}

1;
