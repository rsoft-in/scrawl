import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:scrawler/mobile/markdown_toolbar.dart';
import 'package:scrawler/models/notes.dart';
import 'package:scrawler/widgets/scrawl_empty.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helpers/constants.dart';

class DesktopNoteWidget extends StatefulWidget {
  final Notes note;
  final VoidCallback onSave;
  const DesktopNoteWidget(
      {super.key, required this.note, required this.onSave});

  @override
  State<DesktopNoteWidget> createState() => _DesktopNoteWidgetState();
}

class _DesktopNoteWidgetState extends State<DesktopNoteWidget> {
  bool editMode = false;
  TextEditingController noteController = TextEditingController();
  UndoHistoryController undoController = UndoHistoryController();

  @override
  Widget build(BuildContext context) {
    setState(() {
      noteController.text = widget.note.noteText;
    });
    return widget.note.noteId.isEmpty
        ? EmptyWidget(
            text: 'Select a Note to preview',
            width: MediaQuery.of(context).size.width * 0.4,
            asset: 'images/nothing_to_do.svg')
        : KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              if (event is KeyDownEvent) {
                if (event.logicalKey == LogicalKeyboardKey.escape && editMode) {
                  setState(() {
                    editMode = false;
                  });
                }
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Visibility(
                  visible: editMode,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: MarkdownToolbar(
                      controller: noteController,
                      undoController: undoController,
                      onChange: () {},
                    ),
                  ),
                ),
                Visibility(
                  visible: editMode,
                  child: Expanded(
                    child: Padding(
                      padding: kPaddingLarge,
                      child: TextField(
                        controller: noteController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          hintText: 'Start writing something...',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                        onChanged: (value) {
                          setState(() {
                            widget.note.noteText = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: !editMode,
                  child: Expanded(
                    child: GestureDetector(
                      onDoubleTap: () => setState(() {
                        editMode = true;
                      }),
                      child: Markdown(
                        data: widget.note.noteText,
                        onTapLink: (text, href, title) async =>
                            await _launchUrl(href),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
