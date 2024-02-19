import 'package:flutter/material.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

KeyboardActionsConfig buildConfigDone(BuildContext context, FocusNode fn, {FocusNode? nextFocus , bool isDone = false}) {
  return KeyboardActionsConfig(
    keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
    keyboardBarColor: Colors.grey[200],
    nextFocus: false,
    actions: [
      KeyboardActionsItem(
        focusNode: fn,
        toolbarButtons: [
          //button 1
          //button 2
              (node) {
            return GestureDetector(
              onTap: () {
                if(isDone){
                  node.unfocus();
                }else{
                  FocusScope.of(context).requestFocus(nextFocus);
                }
              },
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8.0),
                child:  Text(
                  isDone ? "DONE" : "NEXT",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            );
          }
        ],
      ),
    ],
  );
}
