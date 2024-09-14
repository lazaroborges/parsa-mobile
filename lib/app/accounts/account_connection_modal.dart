import 'package:flutter/material.dart';

class AccountConnectionModal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: 375,
          height: 812,
          padding: const EdgeInsets.only(
            top: 16,
            left: 16,
            right: 16,
            bottom: 80,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).dialogBackgroundColor, // Access theme here
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 332,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: ShapeDecoration(
                              color: Theme.of(context)
                                  .primaryColorLight, // Access theme here
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 8,
                                  color: Theme.of(context)
                                      .primaryColorDark, // Access theme here
                                ),
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            height: 56,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: Text(
                                    'Criar conta',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall, // Access theme here
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
