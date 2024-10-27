import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scrawler/helpers/constants.dart';
import 'package:scrawler/helpers/note_color.dart';
import 'package:scrawler/helpers/utility.dart';
import 'package:scrawler/mobile/dbhelper.dart';
import 'package:scrawler/mobile/pages/mobile_labels.dart';
import 'package:scrawler/mobile/pages/mobile_notes.dart';
import 'package:scrawler/mobile/pages/settings_page.dart';
import 'package:scrawler/models/label.dart';
import 'package:scrawler/models/notes.dart';
import 'package:scrawler/widgets/scrawl_alert_dialog.dart';
import 'package:scrawler/widgets/scrawl_empty.dart';

class MobileApp extends StatefulWidget {
  const MobileApp({super.key});

  @override
  State<MobileApp> createState() => _MobileAppState();
}

class _MobileAppState extends State<MobileApp> {
  List<Notes> notes = [];
  List<Label> labels = [];
  final dbHelper = DBHelper();
  SearchController searchController = SearchController();
  late PageController pageController =
      PageController(initialPage: 0, keepPage: true);
  int currentPageIndex = 0;
  String selectedLabel = "";

  Future<void> getNotes() async {
    notes = await dbHelper.getNotesAll('', 'note_date DESC');
    setState(() {});
  }

  Future<void> getLabels() async {
    final allLabels = await dbHelper.getLabelsAll();
    labels.clear();
    labels.add(Label('all', 'All', false));
    labels.addAll(allLabels);
    setState(() {});
  }

  Future<void> saveColor(String noteId, int noteColor) async {
    final res = await dbHelper.updateNoteColor(noteId, noteColor);
    if (res) {
      setState(() {
        final index = notes.indexWhere((n) => n.noteId == noteId);
        notes[index].noteColor = noteColor;
      });
    } else {
      print('Unable to save note color!');
    }
  }

  Future<void> setAsFavorite(String noteId, bool value) async {
    final res = await dbHelper.updateNoteFavorite(noteId, value);
    if (res) {
      setState(() {
        final index = notes.indexWhere((n) => n.noteId == noteId);
        notes[index].noteFavorite = value;
      });
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      print('Unable to set favorite!');
    }
  }

  Future<void> setAsArchived(String noteId, int value) async {
    final res = await dbHelper.archiveNote(noteId, value);
    if (res) {
      setState(() {
        final index = notes.indexWhere((n) => n.noteId == noteId);
        notes[index].noteArchived = (value == 1);
      });
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      print('Unable to archive!');
    }
  }

  Future<void> saveLabel(Notes note, String noteLabel) async {
    final res = await dbHelper.updateNoteLabel(note.noteId, noteLabel);
    if (res) {
      setState(() {
        final index = notes.indexWhere((n) => n.noteId == note.noteId);
        notes[index].noteLabel = noteLabel;
      });
      getLabels();
    } else {
      print('Unable to save note label!');
    }
  }

  Future<void> deleteNote(Notes note) async {
    await dbHelper.deleteNotes(note.noteId);
    if (mounted) Navigator.pop(context);
    getNotes();
  }

  void onNavigate(int index) {
    setState(() {
      currentPageIndex = index;
    });
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
  }

  void setLabelFilter(String label) {
    if (label.toLowerCase() == "all") {
      selectedLabel = "";
    } else {
      selectedLabel = label;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getNotes();
    getLabels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(kAppName),
        actions: [
          SearchAnchor(
            // viewSurfaceTintColor: Theme.of(context).colorScheme.surfaceDim,
            builder: (BuildContext context, SearchController controller) {
              return IconButton(
                icon: const Icon(Symbols.search),
                onPressed: () => controller.openView(),
              );
            },
            suggestionsBuilder:
                (BuildContext context, SearchController controller) {
              final List<Notes> suggestions = notes
                  .where((n) => n.noteTitle
                      .toLowerCase()
                      .contains(controller.text.toLowerCase()))
                  .toList();

              return List<ListTile>.generate(
                suggestions.length,
                (int index) {
                  return ListTile(
                    title: Text(suggestions[index].noteTitle),
                    onTap: () {
                      setState(() {
                        controller.closeView(suggestions[index].noteTitle);
                        controller.clear();
                      });
                      openNote(suggestions[index], false, true);
                    },
                  );
                },
              );
            },
          ),
          IconButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(),
                  )),
              icon: const Icon(Symbols.account_circle))
        ],
      ),
      body: notes.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: EmptyWidget(
                  text: 'No Notes',
                  width: MediaQuery.of(context).size.width * 0.7,
                  asset: 'images/nothing_to_do.svg'),
            )
          : PageView(
              controller: pageController,
              onPageChanged: (value) => setState(() {
                currentPageIndex = value;
              }),
              children: [
                dash(),
                myNote(),
              ],
            ),
      bottomNavigationBar: notes.isEmpty
          ? null
          : NavigationBar(
              onDestinationSelected: onNavigate,
              selectedIndex: currentPageIndex,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Symbols.home),
                  label: 'Home',
                  selectedIcon: Icon(
                    Symbols.home,
                    fill: 1,
                  ),
                ),
                NavigationDestination(
                  icon: Icon(Symbols.note_stack),
                  label: 'My Notes',
                  selectedIcon: Icon(
                    Symbols.note_stack,
                    fill: 1,
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: notes.isEmpty
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNote(Notes.empty(), true, false),
        child: const Icon(Symbols.add),
      ),
    );
  }

  Widget dash() {
    final recentNotes = notes.sublist(0, notes.length > 5 ? 5 : notes.length);
    final favNotes = notes
        .where(
          (element) => element.noteFavorite,
        )
        .toList();
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                'Favourites',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            kVSpace,
            favNotes.isEmpty
                ? const Center(
                    child: Text('It\'s empty'),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favNotes.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(kGlobalBorderRadius),
                          onTap: () => openNote(favNotes[index], false, true),
                          onLongPress: () => onNoteLongPressed(favNotes[index]),
                          child: Row(
                            children: [
                              Container(
                                margin: const EdgeInsets.only(left: 4),
                                width: 5,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: NoteColor.getColor(
                                      favNotes[index].noteColor, false),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: Text(favNotes[index].noteTitle),
                                  subtitle: Text(Utility.formatDateTime(
                                      favNotes[index].noteDate)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            kVSpace,
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Text(
                'Recents',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            kVSpace,
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentNotes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(kGlobalBorderRadius),
                    onTap: () => openNote(recentNotes[index], false, true),
                    onLongPress: () => onNoteLongPressed(recentNotes[index]),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 5,
                          height: 50,
                          decoration: BoxDecoration(
                            color: NoteColor.getColor(
                                recentNotes[index].noteColor, false),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(recentNotes[index].noteTitle),
                            subtitle: Text(Utility.formatDateTime(
                                recentNotes[index].noteDate)),
                            trailing: recentNotes[index].noteFavorite
                                ? Icon(
                                    Symbols.favorite,
                                    fill: 1,
                                    color: Colors.red.shade400,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget myNote() {
    final myNotes =
        notes.where((n) => n.noteLabel.contains(selectedLabel)).toList();
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 40,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: labels.length,
                  itemBuilder: (context, index) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      selected: selectedLabel == labels[index].labelName,
                      label: Text(labels[index].labelName),
                      onSelected: (value) =>
                          setLabelFilter(labels[index].labelName),
                    ),
                  ),
                ),
              ),
            ),
            // const SizedBox(height: 4),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: myNotes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(kGlobalBorderRadius),
                    onTap: () => openNote(myNotes[index], false, true),
                    onLongPress: () => onNoteLongPressed(myNotes[index]),
                    child: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 4),
                          width: 5,
                          height: 50,
                          decoration: BoxDecoration(
                            color: NoteColor.getColor(
                                myNotes[index].noteColor, false),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            title: Text(myNotes[index].noteTitle),
                            subtitle: Text(Utility.formatDateTime(
                                myNotes[index].noteDate)),
                            trailing: myNotes[index].noteFavorite
                                ? Icon(
                                    Symbols.favorite,
                                    fill: 1,
                                    color: Colors.red.shade400,
                                  )
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void openNote(Notes note, bool isNew, bool readMode) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileNotesPage(
          note: note,
          isNewNote: isNew,
          readMode: readMode,
        ),
      ),
    );
    if (result) {
      getNotes();
    }
  }

  Future<void> onDeleteClicked(Notes note) async {
    showDialog(
      context: context,
      builder: (context) {
        return ScrawlConfirmDialog(
          title: 'Confirm Delete',
          content: 'Are you sure you want to delete?',
          onAcceptPressed: () {
            Navigator.pop(context);
            deleteNote(note);
          },
        );
      },
    );
  }

  void onNoteLongPressed(Notes note) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: kGlobalOuterPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Symbols.folder_copy),
                  title: const Text('Assign Labels'),
                  onTap: () => assignLabels(note),
                ),
                ListTile(
                  leading: const Icon(Symbols.favorite),
                  title: Text(
                      '${note.noteFavorite ? 'Remove from' : 'Add to'}  Favorites'),
                  onTap: () => setAsFavorite(note.noteId, !note.noteFavorite),
                ),
                const ListTile(
                  leading: Icon(Symbols.palette),
                  title: Text('Change Color'),
                ),
                SizedBox(
                  height: 50,
                  child: ListView(scrollDirection: Axis.horizontal, children: [
                    const SizedBox(
                      width: 48,
                    ),
                    ...NoteColor.colorSet.map((colorSet) => InkWell(
                          onTap: () => changeColor(note, colorSet.code),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: colorSet.color,
                              border: Border.all(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .outlineVariant),
                              borderRadius:
                                  BorderRadius.circular(kBorderRadius),
                            ),
                            child: note.noteColor == colorSet.code
                                ? const Icon(Symbols.check_circle)
                                : null,
                          ),
                        )),
                  ]),
                ),
                ListTile(
                  leading: Icon(Symbols.archive),
                  title: Text('Archive'),
                  onTap: () =>
                      setAsArchived(note.noteId, note.noteArchived ? 0 : 1),
                ),
                ListTile(
                  leading: const Icon(Symbols.delete),
                  title: const Text('Delete'),
                  onTap: () => onDeleteClicked(note),
                ),
              ],
            ),
          );
        });
  }

  void changeColor(Notes note, int colorCode) async {
    if (mounted) {
      Navigator.pop(context);
    }
    saveColor(note.noteId, colorCode);
  }

  void assignLabels(Notes note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MobileLabelsPage(
          noteLabel: note.noteLabel,
        ),
      ),
    );
    if (result != null) {
      if (mounted) {
        Navigator.pop(context);
      }
      saveLabel(note, result);
    }
  }
}
