import 'package:flutter/material.dart';
import 'package:scrawler/helpers/constants.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  @override
  Widget build(BuildContext context) {
    @override
    void initState() {
      showAboutDialog(
          context: context,
          applicationName: kAppName,
          applicationVersion: kAppVersion,
          applicationLegalese: 'RSoft',
          applicationIcon: Image.asset(
            'images/scrawler-desktop.png',
            scale: 6,
          ));
      super.initState();
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            title: const Text('About'),
            centerTitle: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Image.asset(
                        'images/scrawler-desktop.png',
                      ),
                    ),
                  ],
                ),
                ListTile(title: Text(kAppName)),
                ListTile(
                  title: Text('Version'),
                  subtitle: Text(kAppVersion),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
