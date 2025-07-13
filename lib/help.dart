import 'package:flutter/material.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({Key? key}) : super(key: key);

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final List<bool> _expanded = List.generate(7, (_) => false);

  final List<String> _questions = [
    'What is MindMate?',
    'Is MindMate free to use?',
    'Can I customize my experience?',
    'Is my data safe?',
    'Who can use this app?',
    'Do I need an internet connection?',
    'How often should I use MindMate?',
  ];

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    final double scale = screen.width < 400 ? 0.75 : 0.8;
    final double cardWidth = screen.width * scale;
    final double cardHeight = screen.height * scale * 0.92;
    final double cardRadius = 32 * scale;
    final double headerHeight = 70 * scale;
    final double cardPadding = 16 * scale;
    final Color backgroundColor = const Color(0xFFFDE7EF);
    final Color cardColor = const Color(0xFFFEF7F0);
    final Color headerGradientStart = const Color(0xFFE7BBAA);
    final Color headerGradientEnd = const Color(0x00E7BBAA);
    final Color borderColor = const Color(0xFFE7BBAA);
    final Color questionTextColor = Colors.black;
    final Color iconColor = Colors.black;
    final double questionFontSize = 16 * scale;
    final double questionContainerRadius = 12 * scale;
    final double questionContainerPadding = 10 * scale;
    final double questionContainerMargin = 8 * scale;
    final double dropdownIconSize = 24 * scale;
    final double headerFontSize = 22 * scale;
    final double backIconSize = 22 * scale;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                height: headerHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(cardRadius),
                    topRight: Radius.circular(cardRadius),
                  ),
                  gradient: LinearGradient(
                    colors: [headerGradientStart, headerGradientEnd],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: iconColor,
                          size: backIconSize,
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 12 * scale),
                        child: Text(
                          'Help',
                          style: TextStyle(
                            fontSize: headerFontSize,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                            fontFamily: 'Montserrat',
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // FAQ List
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: cardPadding,
                    vertical: cardPadding,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_questions.length, (index) {
                      return Container(
                        margin: EdgeInsets.only(
                          bottom: questionContainerMargin,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: borderColor, width: 1.2),
                          borderRadius: BorderRadius.circular(
                            questionContainerRadius,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              questionContainerRadius,
                            ),
                            onTap: () {
                              setState(() {
                                _expanded[index] = !_expanded[index];
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: questionContainerPadding,
                                horizontal: questionContainerPadding,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _questions[index],
                                      style: TextStyle(
                                        fontSize: questionFontSize,
                                        fontWeight: FontWeight.w500,
                                        color: questionTextColor,
                                        fontFamily: 'Montserrat',
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _expanded[index]
                                        ? Icons.expand_less_rounded
                                        : Icons.expand_more_rounded,
                                    color: iconColor,
                                    size: dropdownIconSize,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
