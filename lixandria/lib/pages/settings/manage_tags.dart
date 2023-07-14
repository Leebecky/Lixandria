/*
Programmer Name: Ms Rebecca Lee Hui Yi, APD3F2211CS(IS)
Program Name: manage_tags.dart
Description: UI Page. Handles the management of tags in the system and relevant business logic.
First Written On: 12/06/2023
Last Edited On:  23/06/2023
 */

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:realm/realm.dart';

import '../../models/model_helper.dart';
import '../../models/tag.dart';
import '../../widgets/customTextfield.dart';

class TagManager extends StatefulWidget {
  const TagManager({super.key});

  @override
  State<TagManager> createState() => _TagManagerState();
}

class _TagManagerState extends State<TagManager> {
  // final _formKey = GlobalKey<FormState>();
  List<Tag> tags = [];
  final formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    tags = getTagData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Tags"),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xff285430),
      ),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 8.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: (tags.isEmpty)
                ? const Center(
                    child: Text(
                    "No tags in the database",
                    style: TextStyle(fontSize: 20),
                  ))
                : ListView.separated(
                    itemCount: tags.length,
                    separatorBuilder: (context, index) => Divider(
                          color: Theme.of(context).primaryColor,
                        ),
                    itemBuilder: (context, index) => Slidable(
                          endActionPane: ActionPane(
                              motion: const DrawerMotion(),
                              children: [
                                //* Delete Tag
                                SlidableAction(
                                  icon: Icons.delete_rounded,
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  onPressed: (context) {
                                    showDialog(
                                        context: context,
                                        builder: (context) => deleteTagDialog(
                                            context,
                                            tagData: tags[index],
                                            onComplete: () => setState(
                                                () => tags = getTagData())));
                                  },
                                ),

                                //* Edit Tag
                                SlidableAction(
                                    icon: Icons.edit_rounded,
                                    backgroundColor: Colors.yellow.shade800,
                                    foregroundColor: Colors.white,
                                    onPressed: (context) {
                                      showDialog(
                                          context: context,
                                          builder: (context) => addTagDialog(
                                              context, formKey,
                                              tagData: tags[index],
                                              isUpdate: true,
                                              onComplete: () => setState(
                                                  () => tags = getTagData())));
                                    }),
                              ]),
                          child: ListTile(
                              title: Text(
                            tags[index].tagDesc!,
                            style: const TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          )),
                        )),
          )),
      //* Add Tag
      persistentFooterButtons: [
        FloatingActionButton(
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => addTagDialog(context, formKey,
                    isUpdate: false,
                    onComplete: () => setState(() {
                          tags = getTagData();
                        })),
              );
            })
      ],
      persistentFooterAlignment: AlignmentDirectional.center,
    );
  }
}

List<Tag> getTagData() {
  RealmResults<Tag> tagDb = ModelHelper.getAllTags();
  return ModelHelper.convertToTag(dataFromResults: tagDb);
}

addTagDialog(context, formKey,
    {required bool isUpdate, Tag? tagData, onComplete}) {
  final tagNameTxt = TextEditingController()
    ..text = (isUpdate) ? tagData!.tagDesc! : "";
  String tagId = (isUpdate) ? tagData!.tagId : ObjectId().toString();
  String headerText = (isUpdate) ? "Edit" : "New";

  return AlertDialog(
    title: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: Text(
        "$headerText Tag",
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    titlePadding: const EdgeInsets.all(0),
    actionsPadding: const EdgeInsets.all(10),
    content: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Form(
          key: formKey,
          child: CustomTextField(tagNameTxt, "Tag Description",
              errorMsg: "Tag Description is required!")),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            Tag data = Tag(
              tagId,
              tagDesc: tagNameTxt.text.trim(),
            );
            String dbResponse = ModelHelper.addNewTag(data, isUpdate);

            onComplete();

            String msg = (dbResponse == "Success")
                ? (isUpdate)
                    ? "Tag updated"
                    : "Tag added"
                : dbResponse;

            Navigator.pop(context, "Cancel");

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(msg),
              showCloseIcon: true,
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Please provide the tag description"),
              showCloseIcon: true,
              duration: Duration(seconds: 1),
            ));
          }
        },
        child: const Text(
          'Confirm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}

deleteTagDialog(context, {required Tag tagData, onComplete}) {
  return AlertDialog(
    title: Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0),
        ),
      ),
      child: const Text(
        "Delete Tag",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    ),
    titlePadding: const EdgeInsets.all(0),
    actionsPadding: const EdgeInsets.all(10),
    content: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Text(
          "By deleting this tag, it will also be removed from all books tagged with it. Are you sure you wish to delete ${tagData.tagDesc}? This action cannot be undone!"),
    ),
    actions: <Widget>[
      TextButton(
        onPressed: () => Navigator.pop(context, 'Cancel'),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          bool success = ModelHelper.deleteTag(tagData.tagId);

          onComplete();

          String msg = (success)
              ? "Tag successfully deleted!"
              : "Unexpected error encountered. Please try again.";

          Navigator.pop(context, "Cancel");

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(msg),
            showCloseIcon: true,
          ));
        },
        child: const Text(
          'Confirm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ],
  );
}
