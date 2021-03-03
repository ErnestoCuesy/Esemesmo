// Regular expressions used:
// ^FNB \u003a\u002d\u0029 R - Match FNB header with similey face and R symbol
// ([\d]+.[\d]{2}) - Match and capture any combination of numbers with decimal point and 2 decimal numbers
// .*@  - Match anything until first @ vendor name separator
// (.*) from.*$ - Match and capture anything until the word ' from ' and match anything until end of line
// Output:
// Group 0 - Fully matched string
// Group 1 - Amount
// Group 2 - Vendor name
const String regExFNB = r'^FNB \u003a\u002d\u0029 R([\d]+.[\d]{2}).*@ (.*) from.*$';

// ^FNB \u003a\u002d\u0029 REVERSAL of R- Match FNB header with similey face and reversal wording and R symbol
// ([\d]+.[\d]{2}) - Match and capture any combination of numbers with decimal point and 2 decimal numbers
// .*$ - match anything else until end of line
// Output:
// Group 0 - Fully matched string
// Grpup 1 - Reversal amount
const String regExFNBreversal = r'^FNB \u003a\u002d\u0029 REVERSAL of R([\d]+.[\d]{2}).*$';

// ^Nedbank confirms: A transaction for R - Match Nedbank header and R symbol
// ([\d]+.[\d]{2}) - Match and capture any combination of numbers with decimal point and 2 decimal numbers
//  at   - Match at separator
// (.*) was.*$ - Match and capture anything until the word ' was ' and match anything until end of line
// Output:
// Group 0 - Fully matched string
// Group 1 - Amount
// Group 2 - Vendor name
const String regExNedbank = r'^Nedbank confirms: A transaction for R([\d]+.[\d]{2}) at (.*) was.*$';

// ^Capitec Bank Purchase - R - Match Capitec header and R symbol
// ([\d]+.[\d]{2}) - Match and capture any combination of numbers with decimal point and 2 decimal numbers
// .*Ref  - Match anything until Ref separator
// [\d]+ - Match one or more decimal numbers and a space
// (.*);.*$ - Match and capture anything until the ; and match anything until end of line
// Output:
// Group 0 - Fully matched string
// Group 1 - Amount
// Group 2 - Vendor name
const String regExCapitec = r'^Capitec Bank Purchase - R([\d]+.[\d]{2}).*Ref [\d]+ (.*);.*$';

// ^Absa: CHEQ[\d]+, - Match Absa header, CHEQ with any number of digits until a comma and a space
// [\d]{2}/[\d]{2}/[\d]{2} - Match date dd/mm/yy and a space
// (.*) reserved R - Match and capture anything until reserved R is found
// ([\d]+.[\d]{2}) - Match and capture any combination of numbers with decimal point and 2 decimal numbers
// for.*$ - Match anything from the word 'for' until end of line
// Output:
// Group 0 - Fully matched string
// Group 1 - Vendor name
// Group 2 - Amount
const String regExAbsa = r'^Absa: CHEQ[\d]+, [\d]{2}/[\d]{2}/[\d]{2} (.*) reserved R([\d]+.[\d]{2}) for.*$';

// ^Absa: CHEQ[\d]+, Wthdr, - Match Absa header, CHEQ with any number of digits and Wthdr indicator with comma and space
// [\d]{2}/[\d]{2}/[\d]{2} - Match date dd/mm/yy and a space
// (.*), R- - Match and capture anything until , R- is found
// ([\d]+.[\d]{2}) - Match and capture any combination of numbers with decimal point and 2 decimal numbers
// , Available.*$ - Match anything from the word ', Available' until end of line
// Output:
// Group 0 - Fully matched string
// Group 1 - ATM withdrawal details
// Group 2 - Amount
const String regExAbsaWthdr = r'^Absa: CHEQ[\d]+, Wthdr, [\d]{2}/[\d]{2}/[\d]{2} (.*), R-([\d]+.[\d]{2}), Available.*$';

// ^Standard Bank: R - Match SBSA header and R symbol
// ([\d]+.[\d]{2}) - Match and capture any combination of numbers with decimal point and 2 decimal numbers
// .* at - Match anything until at is found
// (.*). Avl - Match and capture anything until Avl is found
// .*$ - Match anything until end of line
// Output:
// Group 0 - Fully matched string
// Group 1 - Amount
// Group 2 - Vendor name
const String regExSBSA = r'^Standard Bank: R([\d]+.[\d]{2}).* at (.*). Avl.*$';

// ^WFS : CCRD[\d]+, Pur,  - Match WFS header, CCRD with a number then , Pur,
// [\d]{2}/[\d]{2}/[\d]{2} - Match date dd/mm/yy and a space
// Match AUTHORIZATION,
// (.*), R - Match and capture anything until , R is found
// ([\d]+.[\d]{2}) - Match and capture any combination of numbers with decimal point and 2 decimal numbers
// , Total.*$ - Match Total and anything else until end of line
// Output:
// Group 0 - Fully matched string
// Group 1 - Vendor name
// Group 2 - Amount
const String regExWFS = r'^WFS : CCRD[\d]+, Pur, [\d]{2}/[\d]{2}/[\d]{2} AUTHORIZATION, (.*), R([\d]+.[\d]{2}), Total.*$';

// ^DiscoveryCard: R - Match Discovery header and R symbol
// ([\d]+.[\d]{2}) - Match and capture any combination of numbers with decimal point and 2 decimal numbers
// .*@ - Match anything until @ and a space
// (.*) from - Match and capture anything until from
// .*$ - Match Total and anything else until end of line
// Output:
// Group 0 - Fully matched string
// Group 1 - Amount
// Group 2 - Vendor name
const String regExDisc = r'^DiscoveryCard: R([\d]+.[\d]{2}).*@ (.*) from.*$';

// ^VMCC: CCRD[\d]+, Pur,  - Match VMCC header, CCRD with a number then , Pur,
// [\d]{2}/[\d]{2}/[\d]{2} - Match date dd/mm/yy and a space
// Match AUTHORIZATION,
// (.*), R - Match and capture anything until , R is found
// ([\d]+.[\d]{2}) - Match and capture any combination of numbers with decimal point and 2 decimal numbers
// , Total.*$ - Match Total and anything else until end of line
// Output:
// Group 0 - Fully matched string
// Group 1 - Vendor name
// Group 2 - Amount
const String regExVMCC = r'^VMCC: CCRD[\d]+, Pur, [\d]{2}/[\d]{2}/[\d]{2} AUTHORIZATION, (.*), R([\d]+.[\d]{2}), Total.*$';

const String regExEmail = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

// South African banks array index
const int FNB = 0;
const int FNBREV = 1;
const int NEDBANK = 2;
const int CAPITEC = 3;
const int ABSA = 4;
const int ABSAWTH = 5;
const int SBSA = 6;
const int WFS = 7;
const int DISC = 8;
const int VMCC = 9;

// Iterable patterns array
const List<String> bankPatternsArray = [
  regExFNB,
  regExFNBreversal,
  regExNedbank,
  regExCapitec,
  regExAbsa,
  regExAbsaWthdr,
  regExSBSA,
  regExWFS,
  regExDisc,
  regExVMCC
];

// South African bank names
const List<String> bankNames = [
  'FNB',
  'FNB',
  'Nedbank',
  'Capitec',
  'ABSA',
  'ABSA',
  'Standard Bank',
  'Woolworths',
  'Discovery',
  'Virgin'
];

// Transaction array copy commands
const int COPY_ALL = 0;
const int COPY_CATEGORIZED = 1;
const int COPY_UNCATEGORIZED = 2;
const int COPY_EXCLUDED = 3;
const int COPY_YEAR_MONTH = 4;

// Pull down menu button payment list display options
const String SHOW_CATEGORIZED = 'Show Categorized ';
const String SHOW_UNCATEGORIZED = 'Show Uncategorized ';
const String SHOW_EXCLUDED = 'Show Excluded ';
const String SHOW_ALL = 'Show All ';
const String SEND_VIA_EMAIL = 'Send via email';

// Appbar titles in payments view
const String APPBAR_CATEGORIZED = 'categorized';
const String APPBAR_UNCATEGORIZED = 'uncategorized';
const String APPBAR_EXCLUDED = 'excluded';
const String APPBAR_ALL = 'payments';
