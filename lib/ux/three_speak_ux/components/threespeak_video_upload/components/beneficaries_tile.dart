import 'package:flutter/material.dart';
import 'package:hive_flutter_kit/core/three_speak_core/server_proxy.dart';
import 'package:hive_flutter_kit/core/three_speak_core/video_ops.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/components/user_profile_image.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/components/threespeak_video_upload/utils/add_bene_sheet.dart';
import 'package:hive_flutter_kit/ux/three_speak_ux/widgets/custom_circle_avatar.dart';

class BeneficiariesTile extends StatefulWidget {
  const BeneficiariesTile({
    Key? key,
    required this.userName,
    required this.beneficiaries,
    required this.onChanged,
  }) : super(key: key);

  final String userName;
  final List<BeneficiariesJson> beneficiaries;
  final Function(List<BeneficiariesJson> beneficaries) onChanged;

  @override
  State<BeneficiariesTile> createState() => _BeneficiariesTileState();
}

class _BeneficiariesTileState extends State<BeneficiariesTile> {
  late List<BeneficiariesJson> beneficiaries;

  @override
  void initState() {
    beneficiaries = widget.beneficiaries;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        if (beneficiaries
                .where((element) => !element.isDefault)
                .toList()
                .length >
            0) {
          beneficiariesBottomSheet(context);
        } else {
          showAlertForAddBene(beneficiaries);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  'Video Participants:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Spacer(),
                Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
          Visibility(
            visible: beneficiaries.isNotEmpty,
            child: Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: Wrap(
                spacing: 0,
                runSpacing: 0,
                children: List.generate(
                  beneficiaries.length,
                  (index) => _beneficarieNameTile(theme, index, context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Visibility _beneficarieNameTile(
    ThemeData theme,
    int index,
    BuildContext context,
  ) {
    return Visibility(
      visible: !beneficiaries[index].isDefault,
      child: Container(
        margin: EdgeInsets.only(right: 6, bottom: 8),
        padding: EdgeInsets.only(top: 2, bottom: 2, right: 8, left: 3),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserProfileImage(
              radius: 20,
              userName: beneficiaries[index].account,
            ),
            const SizedBox(width: 5),
            Text(
              beneficiaries[index].account,
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }

  void beneficiariesBottomSheet(BuildContext context) {
    var filteredBenes = beneficiaries;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Container(
            height: 400,
            child: Scaffold(
              appBar: AppBar(
                title: Text('Video Participants'),
                actions: [
                  if (beneficiaries.length < 7)
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        showAlertForAddBene(beneficiaries);
                      },
                      icon: Icon(Icons.add),
                    ),
                ],
              ),
              body: ListView.separated(
                itemBuilder: (c, i) {
                  return ListTile(
                    leading: CustomCircleAvatar(
                      height: 40,
                      width: 40,
                      url: server.userOwnerThumb(filteredBenes[i].account),
                    ),
                    title: Text(filteredBenes[i].account),
                    subtitle: Text(
                      '(${filteredBenes[i].weight} %)',
                    ),
                    trailing: IconButton(
                      onPressed: () {
                        setState(() {
                          beneficiaries.removeWhere(
                            (element) =>
                                element.account == filteredBenes[i].account,
                          );
                        });
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                  );
                },
                separatorBuilder: (c, i) => const Divider(),
                itemCount: filteredBenes.length,
              ),
            ),
          ),
        );
      },
    );
  }

  void showAlertForAddBene(List<BeneficiariesJson> benes) {
    if (beneficiaries.length == 7 || maxLimitReached()) {
      showError('Maximum limit reached');
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) {
          return AddBeneSheet(
            benes: benes,
            onSave: (newBenes) {
              setState(() {
                beneficiaries = newBenes;
              });
              widget.onChanged(newBenes);
            },
          );
        },
      );
    }
  }

  bool maxLimitReached() {
    int weight = 0;
    beneficiaries.forEach((element) {
      weight += element.weight;
    });
    if (weight >= 99) {
      return true;
    }
    return false;
  }

  void showError(String string) {
    var snackBar = SnackBar(content: Text('Error: $string'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
