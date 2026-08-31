import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isIos = !kIsWeb && Platform.isIOS;
    return isIos
        ? const CupertinoApp(
            debugShowCheckedModeBanner: false,
            home: DashboardScreen(isIos: true),
          )
        : const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: DashboardScreen(isIos: false),
          );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.isIos});
  final bool isIos;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, size) {
      // iPads stay tablet-sized in portrait and landscape.
      final isIpad = isIos && size.biggest.shortestSide >= 600;
      if (isIpad) return const _Tablet(isIos: true);
      if (size.maxWidth >= 900) return const _Desktop();
      if (size.maxWidth >= 600) return _Tablet(isIos: isIos);
      return isIos ? const _IosPhone() : const _AndroidPhone();
    },
  );
}

const _canvas = Color(0xFFF4FBFD);
const _panel = Color(0xFFE7E7E7);
const _metric = Color(0xFFDCDCDC);
const _ink = Color(0xFF1C2225);
const _bar = Color(0xFF3C3C3C);

class _Desktop extends StatelessWidget {
  const _Desktop();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _canvas,
    body: SafeArea(
      child: Row(
        children: [
          const _Sidebar(),
          const VerticalDivider(width: 1, color: Color(0xFFD8DEE0)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 27, 25, 25),
              child: const _DesktopBody(),
            ),
          ),
        ],
      ),
    ),
  );
}

class _DesktopBody extends StatelessWidget {
  const _DesktopBody();
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'DASHBOARD',
        style: TextStyle(
          fontSize: 25,
          letterSpacing: 2.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 22),
      const _Metrics(columns: 4),
      const SizedBox(height: 14),
      const Expanded(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _ActivityList(
                labels: const ["Today's Activity", 'Recent Tasks', 'Progress'],
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(flex: 4, child: _Summary()),
          ],
        ),
      ),
    ],
  );
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 184,
    child: Column(
      children: [
        const SizedBox(height: 30),
        const Icon(Icons.favorite, color: _ink, size: 35),
        const SizedBox(height: 51),
        ..._menuItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(left: 27, bottom: 20),
            child: Row(
              children: [
                Icon(item.$1, size: 14, color: _ink),
                const SizedBox(width: 14),
                Text(
                  item.$2,
                  style: const TextStyle(
                    fontSize: 8,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Tablet extends StatefulWidget {
  const _Tablet({required this.isIos});
  final bool isIos;

  @override
  State<_Tablet> createState() => _TabletState();
}

class _TabletState extends State<_Tablet> {
  bool _drawerOpen = false;

  Widget get _content => Column(
    children: [
      _TopBar(
        cupertino: widget.isIos,
        onMenu: () => setState(() => _drawerOpen = true),
      ),
      const Expanded(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              _Metrics(columns: 4),
              SizedBox(height: 11),
              Expanded(child: _ActivityList(labels: ['', '', '', '', ''])),
            ],
          ),
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    if (!widget.isIos) {
      return Scaffold(
        backgroundColor: _canvas,
        drawer: const Drawer(child: _DrawerContents()),
        body: SafeArea(
          child: Column(
            children: [
              Builder(
                builder: (context) =>
                    _TopBar(onMenu: () => Scaffold.of(context).openDrawer()),
              ),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      _Metrics(columns: 4),
                      SizedBox(height: 11),
                      Expanded(
                        child: _ActivityList(labels: ['', '', '', '', '']),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return CupertinoPageScaffold(
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, size) {
            final drawerWidth = size.maxWidth * .42;
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(child: _content),
                if (_drawerOpen) ...[
                  Positioned.fill(
                    left: drawerWidth,
                    child: GestureDetector(
                      onTap: () => setState(() => _drawerOpen = false),
                      child: const ColoredBox(color: Color(0x88000000)),
                    ),
                  ),
                  SizedBox(
                    width: drawerWidth,
                    child: const _DrawerContents(cupertino: true),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AndroidPhone extends StatelessWidget {
  const _AndroidPhone();
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _canvas,
    drawer: const Drawer(child: _DrawerContents()),
    body: SafeArea(
      child: Column(
        children: [
          Builder(
            builder: (context) =>
                _TopBar(onMenu: () => Scaffold.of(context).openDrawer()),
          ),
          const Expanded(child: _PhoneBody()),
        ],
      ),
    ),
  );
}

class _IosPhone extends StatelessWidget {
  const _IosPhone();
  @override
  Widget build(BuildContext context) => CupertinoPageScaffold(
    child: SafeArea(
      child: LayoutBuilder(
        builder: (context, size) {
          final drawerWidth = size.maxWidth * .55;
          return Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(
                child: Column(
                  children: [
                    _TopBar(cupertino: true),
                    Expanded(child: _PhoneBody()),
                  ],
                ),
              ),
              Positioned.fill(
                left: drawerWidth,
                child: const ColoredBox(color: Color(0x88000000)),
              ),
              SizedBox(
                width: drawerWidth,
                child: const _DrawerContents(cupertino: true),
              ),
            ],
          );
        },
      ),
    ),
  );
}

class _TopBar extends StatelessWidget {
  const _TopBar({this.onMenu, this.cupertino = false});
  final VoidCallback? onMenu;
  final bool cupertino;

  @override
  Widget build(BuildContext context) => Container(
    height: 43,
    color: _bar,
    alignment: Alignment.centerLeft,
    child: cupertino
        ? CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            minSize: 0,
            onPressed: onMenu,
            child: const Icon(
              CupertinoIcons.bars,
              color: Colors.white,
              size: 18,
            ),
          )
        : IconButton(
            onPressed: onMenu,
            icon: const Icon(Icons.menu, color: Colors.white, size: 18),
          ),
  );
}

class _PhoneBody extends StatelessWidget {
  const _PhoneBody();
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      children: [
        const _Metrics(columns: 2),
        const SizedBox(height: 10),
        const Expanded(child: _ActivityList(labels: ['', '', ''])),
      ],
    ),
  );
}

class _Metrics extends StatelessWidget {
  const _Metrics({required this.columns});
  final int columns;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: columns == 2 ? 158 : 74,
    child: GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.fromLTRB(14, 15, 12, 10),
        decoration: BoxDecoration(
          color: _metric,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _ActivityList extends StatelessWidget {
  const _ActivityList({required this.labels});
  final List<String> labels;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: List.generate(
      labels.length,
      (index) => Container(
        height: 70,
        width: double.infinity,
        margin: EdgeInsets.only(bottom: index == labels.length - 1 ? 0 : 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: _panel,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            if (labels[index].isNotEmpty)
              Text(
                labels[index],
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            const Spacer(),
            Container(width: 70, height: 10, color: const Color(0xFFDCDCDC)),
          ],
        ),
      ),
    ),
  );
}

class _Summary extends StatelessWidget {
  const _Summary();
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: _metric,
      borderRadius: BorderRadius.circular(4),
    ),
    child: const Text(
      'SUMMARY',
      style: TextStyle(
        fontSize: 16,
        letterSpacing: 1.7,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _DrawerContents extends StatelessWidget {
  const _DrawerContents({this.cupertino = false});
  final bool cupertino;
  @override
  Widget build(BuildContext context) => ColoredBox(
    color: _canvas,
    child: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 28),
          const Center(child: Icon(Icons.favorite, color: _ink, size: 35)),
          const SizedBox(height: 50),
          ..._menuItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(left: 28, bottom: 22),
              child: Row(
                children: [
                  Icon(
                    cupertino ? _cupertinoIcon(item.$2) : item.$1,
                    color: const Color(0xFF535C5E),
                    size: 18,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    item.$2,
                    style: const TextStyle(
                      fontSize: 13,
                      letterSpacing: 2.1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  IconData _cupertinoIcon(String label) => switch (label) {
    'DASHBOARD' => CupertinoIcons.home,
    'SETTINGS' => CupertinoIcons.gear,
    'ABOUT' => CupertinoIcons.info,
    _ => CupertinoIcons.square_arrow_left,
  };
}

const _menuItems = <(IconData, String)>[
  (Icons.home, 'DASHBOARD'),
  (Icons.settings, 'SETTINGS'),
  (Icons.info, 'ABOUT'),
  (Icons.logout, 'LOGOUT'),
];
