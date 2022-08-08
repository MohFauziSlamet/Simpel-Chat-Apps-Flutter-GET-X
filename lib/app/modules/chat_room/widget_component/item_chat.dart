import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItemChat extends StatelessWidget {
  ItemChat({
    Key? key,
    required this.isSender,
    required this.msg,
    required this.time,
  }) : super(key: key);

  final bool isSender;
  final String msg;
  final String time;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onLongPress: () {},
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 15),
        alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: isSender ? Colors.deepPurple : Colors.pink,
                  borderRadius: isSender
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        )),
              padding: isSender
                  ? const EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                      left: 5,
                      right: 10,
                    )
                  : const EdgeInsets.only(
                      top: 15,
                      bottom: 15,
                      left: 10,
                      right: 5,
                    ),
              child: Text(
                msg,
                textAlign: isSender ? TextAlign.right : TextAlign.left,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              DateFormat.jm().format(DateTime.parse(time)),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
