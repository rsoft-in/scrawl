import 'package:bnotes/helpers/constants.dart';
import 'package:bnotes/helpers/note_color.dart';
import 'package:bnotes/helpers/utility.dart';
import 'package:bnotes/models/notes.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class NoteListItemWidget extends StatefulWidget {
  Notes note;
  int selectedIndex;
  bool isSelected = false;
  VoidCallback? onTap;
  NoteListItemWidget(
      {Key? key,
      required this.note,
      required this.selectedIndex,
      required this.isSelected,
      this.onTap})
      : super(key: key);

  @override
  State<NoteListItemWidget> createState() => _NoteListItemWidgetState();
}

class _NoteListItemWidgetState extends State<NoteListItemWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: 10.0,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: widget.onTap,
        child: Container(
          padding: kGlobalCardPadding * 2,
          decoration: BoxDecoration(
            color: kLightPrimary,
            border: widget.isSelected
                ? Border.all(color: kLightStroke, width: 2)
                : Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.note.noteTitle,
                        style: const TextStyle(
                          fontSize: 14.0,
                        ),
                      ),
                      kVSpace,
                      Text(
                        Utility.formatDateTime(widget.note.noteDate),
                        style: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(widget.note.noteLabel),
              Container(
                width: 5,
                height: 50,
                decoration: BoxDecoration(
                  color: NoteColor.getColor(widget.note.noteColor, false),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
