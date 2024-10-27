import 'package:flutter/material.dart';
import 'package:scrawler/helpers/constants.dart';
import 'package:scrawler/mobile/dbhelper.dart';
import 'package:scrawler/models/label.dart';
import 'package:uuid/uuid.dart';

class MobileLabelsPage extends StatefulWidget {
  final String noteLabel;
  const MobileLabelsPage({super.key, required this.noteLabel});

  @override
  State<MobileLabelsPage> createState() => _MobileLabelsPageState();
}

class _MobileLabelsPageState extends State<MobileLabelsPage> {
  DBHelper dbHelper = DBHelper();
  List<Label> labels = [];
  TextEditingController labelController = TextEditingController();
  List<String> selectedLabels = [];
  bool formDirty = false;

  Future<void> getLabels() async {
    labels = await dbHelper.getLabelsAll();
    for (var element in labels) {
      if (selectedLabels.contains(element.labelName)) {
        element.selected = true;
      }
    }
    setState(() {});
  }

  Future<void> addLabel() async {
    var labelId = const Uuid().v1();
    final label = Label(labelId, labelController.text, true);
    final result = await dbHelper.insertLabel(label);
    if (!result && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to add Label'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      formDirty = true;
      selectedLabels.add(label.labelName);
      getLabels();
    }
    labelController.clear();
  }

  @override
  void initState() {
    super.initState();
    getLabels();
    selectedLabels = widget.noteLabel.split(',');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }
        if (formDirty) {
          Navigator.pop(context, selectedLabels.join(','));
        } else {
          Navigator.pop(context, null);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Labels'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            Padding(
              padding: kGlobalOuterPadding,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: labelController,
                      maxLength: 30,
                      decoration: const InputDecoration(
                        hintText: 'New Label',
                        counterText: '',
                      ),
                    ),
                  ),
                  kHSpace,
                  FilledButton.tonal(
                    onPressed: () => addLabel(),
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: labels.length,
                itemBuilder: (context, index) => CheckboxListTile(
                  title: Text(labels[index].labelName),
                  value: labels[index].selected,
                  onChanged: (value) => setState(() {
                    setState(() {
                      formDirty = true;
                      labels[index].selected = value!;
                      selectedLabels.clear();
                      for (var e in labels) {
                        if (e.selected) {
                          selectedLabels.add(e.labelName);
                        }
                      }
                    });
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
