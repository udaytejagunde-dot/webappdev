import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WebDevLibraryApp());
}

class Program {
  final String id;
  final int module;
  final String moduleTitle;
  final String type;
  final String title;
  final String description;
  final String language;
  final String code;
  final String output;

  const Program({
    required this.id,
    required this.module,
    required this.moduleTitle,
    required this.type,
    required this.title,
    required this.description,
    required this.language,
    required this.code,
    required this.output,
  });

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        id: json['id'],
        module: json['module'],
        moduleTitle: json['moduleTitle'],
        type: json['type'],
        title: json['title'],
        description: json['description'],
        language: json['language'],
        code: json['code'],
        output: json['output'],
      );
}

class WebDevLibraryApp extends StatefulWidget {
  const WebDevLibraryApp({super.key});

  @override
  State<WebDevLibraryApp> createState() => _WebDevLibraryAppState();
}

class _WebDevLibraryAppState extends State<WebDevLibraryApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebDev Code Library',
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3157C8)),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8EA7FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: LibraryHome(
        isDark: isDark,
        onThemeChanged: (value) => setState(() => isDark = value),
      ),
    );
  }
}

class LibraryHome extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onThemeChanged;

  const LibraryHome({
    super.key,
    required this.isDark,
    required this.onThemeChanged,
  });

  @override
  State<LibraryHome> createState() => _LibraryHomeState();
}

class _LibraryHomeState extends State<LibraryHome> {
  final TextEditingController searchController = TextEditingController();
  List<Program> programs = [];
  bool loading = true;
  String selectedType = 'All';
  int selectedModule = 0;

  @override
  void initState() {
    super.initState();
    loadPrograms();
    searchController.addListener(() => setState(() {}));
  }

  Future<void> loadPrograms() async {
    final raw = await rootBundle.loadString('assets/data/programs.json');
    final List<dynamic> decoded = jsonDecode(raw);
    setState(() {
      programs = decoded.map((e) => Program.fromJson(e)).toList();
      loading = false;
    });
  }

  List<Program> get filteredPrograms {
    final query = searchController.text.trim().toLowerCase();
    return programs.where((p) {
      final matchesModule = selectedModule == 0 || p.module == selectedModule;
      final matchesType = selectedType == 'All' || p.type == selectedType;
      final matchesQuery = query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query) ||
          p.moduleTitle.toLowerCase().contains(query);
      return matchesModule && matchesType && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.code_rounded),
            SizedBox(width: 9),
            Text('WebDev Code Library', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: widget.isDark ? 'Light mode' : 'Dark mode',
            onPressed: () => widget.onThemeChanged(!widget.isDark),
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(theme)),
                    SliverToBoxAdapter(child: _buildSearch(theme)),
                    SliverToBoxAdapter(child: _buildModuleSelector(theme)),
                    SliverToBoxAdapter(child: _buildTypeSelector()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 20, 18, 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                selectedModule == 0
                                    ? 'All programs'
                                    : 'Module $selectedModule programs',
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text('${filteredPrograms.length} programs',
                                style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    ),
                    if (filteredPrograms.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: Text('No programs found. Try another search.')),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => ProgramCard(
                              program: filteredPrograms[index],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProgramDetail(program: filteredPrograms[index]),
                                ),
                              ),
                            ),
                            childCount: filteredPrograms.length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF172B63), Color(0xFF3157C8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('YOUR FRONT-END STUDY SPACE',
              style: TextStyle(color: Color(0xFFD8E2FF), letterSpacing: 1.1, fontSize: 11)),
          const SizedBox(height: 9),
          const Text('Learn. Explore. Copy.',
              style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          const Text('All your Web Application Development practical codes in one place.',
              style: TextStyle(color: Color(0xFFE4EAFE), height: 1.4)),
          const SizedBox(height: 18),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _headerChip(Icons.menu_book_outlined, '5 Modules'),
              _headerChip(Icons.code, '${programs.length} Programs'),
              _headerChip(Icons.content_copy, 'Copy code'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ]),
      );

  Widget _buildSearch(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search programs, topics, or modules...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: searchController.clear,
                  icon: const Icon(Icons.close),
                ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildModuleSelector(ThemeData theme) {
    const modules = [
      'All',
      'HTML, CSS & JS',
      'React Basics',
      'Components & State',
      'Routing',
      'APIs & Advanced',
    ];
    return SizedBox(
      height: 58,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(18, 13, 18, 5),
        scrollDirection: Axis.horizontal,
        itemCount: modules.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = selectedModule == index;
          return ChoiceChip(
            label: Text(modules[index]),
            selected: selected,
            onSelected: (_) => setState(() => selectedModule = index),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 0),
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'All', label: Text('All')),
          ButtonSegment(value: 'Hands-on', label: Text('Hands-on')),
          ButtonSegment(value: 'Case Study', label: Text('Case studies')),
        ],
        selected: {selectedType},
        onSelectionChanged: (value) => setState(() => selectedType = value.first),
        showSelectedIcon: false,
      ),
    );
  }
}

class ProgramCard extends StatelessWidget {
  final Program program;
  final VoidCallback onTap;

  const ProgramCard({super.key, required this.program, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isHandsOn = program.type == 'Hands-on';
    return Card(
      margin: const EdgeInsets.only(bottom: 11),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(isHandsOn ? Icons.terminal : Icons.article_outlined,
                    color: theme.colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(program.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 5),
                  Text('Module ${program.module} • ${program.type}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary)),
                  const SizedBox(height: 4),
                  Text(program.description, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall),
                ]),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class ProgramDetail extends StatelessWidget {
  final Program program;
  const ProgramDetail({super.key, required this.program});

  Future<void> copyCode(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: program.code));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code copied to clipboard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(program.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Wrap(spacing: 8, runSpacing: 8, children: [
                Chip(label: Text('Module ${program.module}')),
                Chip(label: Text(program.type)),
                Chip(label: Text(program.language.toUpperCase())),
              ]),
              const SizedBox(height: 12),
              Text(program.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(program.description, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
              const SizedBox(height: 22),
              Row(
                children: [
                  const Expanded(child: Text('Source code', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
                  FilledButton.icon(
                    onPressed: () => copyCode(context),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy code'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF111827)
                      : const Color(0xFF172033),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SelectableText(
                  program.code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    height: 1.55,
                    color: Color(0xFFE6ECF5),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text('Expected output', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.lightbulb_outline, color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 10),
                  Expanded(child: Text(program.output, style: const TextStyle(height: 1.5))),
                ]),
              ),
              const SizedBox(height: 20),
              Text('Note: This app displays code for study and copying. It does not execute programs.',
                  style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }
}
