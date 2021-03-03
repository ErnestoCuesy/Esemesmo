import 'package:flutter/material.dart';
import '../resources/globals.dart';

class EmailCapture extends ModalRoute<void> {
  double width;
  String newRecipientEmailAddress;
  final formKey = GlobalKey<FormState>();

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.black.withOpacity(0.5);

  @override
  String get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    // This makes sure that text and other content follows the material style
    return Material(
      type: MaterialType.transparency,
      // make sure that the overlay content is not cut off
      child: SafeArea(
        child: _buildOverlayContent(context),
      ),
    );
  }

  Widget recipientEmailAddress() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        onSaved: (String email) {
          this.newRecipientEmailAddress = email;
        },
        decoration: const InputDecoration(
            labelText: "Recipient's email address",
            hintText: 'Enter email address'),
        initialValue: globalData.preferences.recipientEmailAddress,
        validator: validateEmailAddress,
      ),
    );
  }

  String validateEmailAddress(String email) {
    RegExp emailMatchPattern = RegExp('$regExEmail');
    Iterable<Match> matches = emailMatchPattern.allMatches(email);
    if (matches.length <= 0) {
      return 'Invalid email address';
    }
  }

  Widget _buildOverlayContent(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return Center(
      heightFactor: 200.0,
      child: Container(
        color: Colors.grey[50],
        height: width > 600.0 ? 300.0 : 220.0,
        width: width > 600.0 ? 450.0 : 260.0,
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              recipientEmailAddress(),
              Padding(
                padding: EdgeInsets.only(top: width > 600.0 ? 210.0 : 60.0),
                child: FloatingActionButton(
                  backgroundColor: Colors.pink[100],
                  child: Icon(Icons.send),
                  onPressed: () {
                    if (formKey.currentState.validate()) {
                      formKey.currentState.save();
                      dBProvider.updatePreferencesEmailAddress(
                          newRecipientEmailAddress);
                      globalData.preferences.recipientEmailAddress =
                          newRecipientEmailAddress;
                      Navigator.pop(context);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    // You can add your own animations for the overlay content
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: animation,
        child: child,
      ),
    );
  }
}
