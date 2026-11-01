import 'package:flutter/material.dart';

import '../helper/database_helper.dart';
import '../models/task.dart';

class CategoryTheme {
  const CategoryTheme({
    required this.textColor,
    required this.borderColor,
    required this.backgroundColor,
  });

  final Color textColor;
  final Color borderColor;
  final Color backgroundColor;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedFilterIndex;
  late int _selectedCategoryIndex;
  final List<String> _filterOptions = ['Semua', 'Selesai', 'Belum'];

  final List<Map<String, dynamic>> _category = [
    {
      'category': 'Semua Kategori',
      'icon': Icons.list,
      'theme': const CategoryTheme(
        textColor: Color(0xFF2563EB),
        borderColor: Color(0xFFBFDBFE),
        backgroundColor: Color(0xFFEFF6FF),
      ),
    },
    {
      'category': 'Pekerjaan',
      'icon': Icons.work_outline,
      'theme': const CategoryTheme(
        textColor: Color(0xFF2563EB),
        borderColor: Color(0xFFBFDBFE),
        backgroundColor: Color(0xFFEFF6FF),
      ),
    },
    {
      'category': 'Ibadah',
      'icon': Icons.bedtime_outlined,
      'theme': const CategoryTheme(
        textColor: Color(0xFF059669),
        borderColor: Color(0xFFA7F3D0),
        backgroundColor: Color(0xFFECFDF5),
      ),
    },
    {
      'category': 'Belajar',
      'icon': Icons.menu_book_outlined,
      'theme': const CategoryTheme(
        textColor: Color(0xFFD97706),
        borderColor: Color(0xFFFDE68A),
        backgroundColor: Color(0xFFFFFBEB),
      ),
    },
    {
      'category': 'Kesehatan',
      'icon': Icons.monitor_heart_outlined,
      'theme': const CategoryTheme(
        textColor: Color(0xFFDC2626),
        borderColor: Color(0xFFFECACA),
        backgroundColor: Color(0xFFFEF2F2),
      ),
    },
    {
      'category': 'Rumah',
      'icon': Icons.home_outlined,
      'theme': const CategoryTheme(
        textColor: Color(0xFF7C3AED),
        borderColor: Color(0xFFDDD6FE),
        backgroundColor: Color(0xFFF5F3FF),
      ),
    },
    {
      'category': 'Santai',
      'icon': Icons.coffee_outlined,
      'theme': const CategoryTheme(
        textColor: Color.fromARGB(255, 106, 137, 53),
        borderColor: Color.fromARGB(126, 164, 118, 39),
        backgroundColor: Color.fromARGB(67, 176, 138, 72),
      ),
    },
  ];

  Future<void> _loadTask({bool delay = true}) async {
    if (delay) {
      await Future.delayed(const Duration(seconds: 2));
    }

    final task = await DatabaseHelper.instance.getTasks();
    if (!mounted) return;
    setState(() {
      _tasks = task;
      _isLoading = false;
    });
  }

  Future<void> _saveTask(BuildContext sheetContext, Task? oldTask) async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      id: oldTask?.id,
      name: nameController.text.trim(),
      description: descController.text.trim(),
      time: timeController.text,
      priority: selectedPriority!,
      category: selectedCategory!,
      isDone: oldTask?.isDone ?? false,
    );

    if (oldTask == null) {
      await DatabaseHelper.instance.insertTask(task);
    } else {
      await DatabaseHelper.instance.updateTask(task);
    }

    if (!sheetContext.mounted) return;
    Navigator.pop(sheetContext);
    setState(() {
      _isLoading = true;
    });
    await _loadTask();
  }

  List<Task> get _filteredTask {
    final selectedCategory = _category[_selectedCategoryIndex]['category'];
    return _tasks.where((t) {
      final statusMatch = switch (_selectedFilterIndex) {
        1 => t.isDone,
        2 => !t.isDone,
        _ => true,
      };
      final categoryMatch =
          _selectedCategoryIndex == 0 || t.category == selectedCategory;
      return statusMatch && categoryMatch;
    }).toList();
  }

    Future<void> _deleteTask(Task task) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Hapus Task?',
          style: TextStyle(color: Colors.blueAccent),
        ),
        content: Text('"${task.name}" akan dihapus permanen!'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (yes != true) return;
    await DatabaseHelper.instance.deleteTask(task.id!);
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    await _loadTask();
  }

  List<Task> _tasks = [];

  bool _isLoading = true;

  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  final timeController = TextEditingController();
  String? selectedPriority;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    _selectedFilterIndex = 0;
    _selectedCategoryIndex = 0;
    _loadTask();
  }

  Padding top_card() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xffF1F6FE),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: const Color(0xffDFEBFE), width: 1.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: const Icon(Icons.auto_awesome, color: Colors.white),
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROGRES HARI INI',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff7D8693),
                        ),
                      ),
                      Text(
                        '2 dari 5 Selesai',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff4C5668),
                        ),
                      ),
                    ],
                  ),
                  const Column(
                    children: [
                      Text(
                        '40%',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.normal,
                          color: Color(0xff5DA7FE),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 21.0),
              Column(
                children: [
                  LinearProgressIndicator(
                    value: 0.4,
                    color: Colors.blueAccent,
                    backgroundColor: const Color(0xffDFEBFE),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ],
              ),
              const SizedBox(height: 21.0),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Langkah awal yang baik, lanjutkan...',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xff7D8693),
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outlined,
                        color: Colors.green,
                        size: 20.0,
                      ),
                      Text('2'),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_outlined,
                        color: Colors.orange,
                        size: 20.0,
                      ),
                      Text('2'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Padding filter_area() {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff4A5162),
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 4.0,
            bottom: 4.0,
            left: 8.0,
            right: 8.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _filterOptions.asMap().entries.map((entries) {
              return Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    backgroundColor: entries.key == _selectedFilterIndex
                        ? Colors.white
                        : const Color(0xff4A5162),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedFilterIndex = entries.key;
                    });
                  },
                  child: Text(
                    entries.value,
                    style: TextStyle(
                      color: entries.key == _selectedFilterIndex
                          ? Colors.black
                          : const Color(0xff5E6F88),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Padding category_area() {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          height: 50.0,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: _category.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: index == _selectedCategoryIndex
                        ? Colors.blueAccent
                        : Colors.white,
                    foregroundColor: index == _selectedCategoryIndex
                        ? Colors.white
                        : const Color(0xff717B8B),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                      side: const BorderSide(color: Color(0xffE2E7F1)),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedCategoryIndex = index;
                    });
                  },
                  icon: Icon(_category[index]['icon']),
                  label: Text(
                    _category[index]['category'],
                    style: TextStyle(
                      fontWeight: _selectedCategoryIndex == index
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

    void _showAddTaskModal(BuildContext context, {Task? task}) {
    nameController.text = task?.name ?? '';
    descController.text = task?.description ?? '';
    timeController.text = task?.time ?? '';
    selectedPriority = task?.priority;
    selectedCategory = task?.category;

    InputDecoration inputDecoration({String? hintText, Widget? suffixIcon}) {
      return InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xff94A3B8), fontSize: 14),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14.0,
          vertical: 14.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xffCBD5E1), width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color(0xffCBD5E1), width: 1.0),
        ),
      );
    }

    const labelStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Color(0xff94A3B8),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.58,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12.0),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(2.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        task == null ? 'Tambah Kegiatan Baru' : 'Ubah Kegiatan',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12.0),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xffE2E8F0),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('NAMA KEGIATAN', style: labelStyle),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: nameController,
                                decoration: inputDecoration(
                                  hintText: 'Contoh: Meeting, Belajar, Sholat',
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              const Text(
                                'CATATAN / DESKTIPSI DETAIL',
                                style: labelStyle,
                              ),
                              const SizedBox(height: 8.0),
                              TextFormField(
                                controller: descController,
                                maxLines: 3,
                                decoration: inputDecoration(
                                  hintText:
                                      'Detail Kegiatan, Lokasi, Ataupun Target',
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'JAM KEGIATAN',
                                          style: labelStyle,
                                        ),
                                        const SizedBox(height: 8.0),
                                        TextFormField(
                                          controller: timeController,
                                          readOnly: true,
                                          onTap: () async {
                                            final picked = await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                              builder: (context, child) {
                                                return MediaQuery(
                                                  data: MediaQuery.of(context)
                                                      .copyWith(
                                                        alwaysUse24HourFormat:
                                                            true,
                                                      ),
                                                  child: child!,
                                                );
                                              },
                                            );
                                            if (picked != null) {
                                              final hh = picked.hour
                                                  .toString()
                                                  .padLeft(2, '0');
                                              final mm = picked.minute
                                                  .toString()
                                                  .padLeft(2, '0');
                                              setModalState(() {
                                                timeController.text = '$hh:$mm';
                                              });
                                            }
                                          },
                                          decoration: inputDecoration(
                                            hintText: 'HH:mm',
                                            suffixIcon: const Icon(
                                              Icons.access_time_outlined,
                                              color: Color(0xff64748B),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12.0),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'PRIORITAS',
                                          style: labelStyle,
                                        ),
                                        const SizedBox(height: 8.0),
                                        DropdownButtonFormField<String>(
                                          initialValue: selectedPriority,
                                          validator: (v) => v == null ? 'tidak boleh kosong' : null,
                                          hint: const Text(
                                            'Pilih',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 14,
                                            ),
                                          ),
                                          dropdownColor: Colors.white,
                                          decoration: inputDecoration(),
                                          items: ['rendah', 'sedang', 'tinggi']
                                              .map(
                                                (p) => DropdownMenuItem<String>(
                                                  value: p,
                                                  child: Text(p),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            setModalState(() {
                                              selectedPriority = val;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              const Text('KATEGORI KEGIATAN', style: labelStyle),
                              const SizedBox(height: 8.0),
                              DropdownButtonFormField<String>(
                                initialValue: selectedCategory,
                                validator: (v) => v == null ? 'tidak boleh kosong' : null,
                                hint: const Text(
                                  'Pilih Kategori',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                  ),
                                ),
                                dropdownColor: Colors.white,
                                decoration: inputDecoration(),
                                items: _category
                                    .where(
                                      (c) => c['category'] != 'Semua Kategori',
                                    )
                                    .map(
                                      (c) => DropdownMenuItem<String>(
                                        value: c['category'] as String,
                                        child: Row(
                                          children: [
                                            Icon(
                                              c['icon'] as IconData,
                                              size: 20,
                                              color: Colors.blueAccent,
                                            ),
                                            const SizedBox(width: 10.0),
                                            Text(
                                              c['category'] as String,
                                              style: const TextStyle(
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (val) {
                                  setModalState(() {
                                    selectedCategory = val;
                                  });
                                },
                              ),
                              const SizedBox(height: 24.0),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    _saveTask(context, task);
                                  },
                                  icon: const Icon(Icons.check, size: 20),
                                  label: Text(
                                    task == null ? 'Tambah Ke List' : 'Ubah List',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kegiatan Harian',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        onPressed: () => _showAddTaskModal(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: SafeArea(
        child: Column(
          children: [top_card(), filter_area(), category_area(), taskList()],
        ),
      ),
    );
  }

  Expanded taskList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(color: Colors.blueAccent),
        ),
      );
    }

    final tasks = _filteredTask;
    if (tasks.isEmpty) {
      return const Expanded(
        child: Center(
          child: Text(
            'Tidak ada kegiatan',
            style: TextStyle(fontSize: 16, color: Color(0xff94A3B8)),
          ),
        ),
      );
    }
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0, left: 16.0),
        child: ListView.builder(
          itemCount: tasks.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            final task = tasks[index];
            final cat = _category.firstWhere(
              (item) => item['category'] == task.category,
            );
            final CategoryTheme? theme = cat['theme'] as CategoryTheme?;

            return Card(
              color: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.0),
                side: const BorderSide(color: Color(0xffE1E7F1)),
              ),
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            activeColor: Colors.blueAccent,
                            side: const BorderSide(color: Color(0xff778294)),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4.0),
                              ),
                            ),
                            value: task.isDone,
                            onChanged: (checked) async {
                              await DatabaseHelper.instance.updateTask(
                                task.copyWith(isDone: checked ?? false),
                              );
                              await _loadTask(delay: false);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: SizedBox(
                          width: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                task.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                task.description,
                                style: const TextStyle(
                                  color: Color(0xff778294),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.access_time_outlined,
                                          size: 16.0,
                                          color: Color(0xff778294),
                                        ),
                                        Text(
                                          task.time,
                                          style: const TextStyle(
                                            color: Color(0xff778294),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: theme?.backgroundColor,
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      border: Border.all(
                                        color:
                                            theme?.borderColor ??
                                            Colors.transparent,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                        left: 8.0,
                                        top: 4.0,
                                        bottom: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            cat['icon'] as IconData,
                                            size: 16.0,
                                            color: theme?.textColor,
                                          ),
                                          Text(
                                            task.category,
                                            style: TextStyle(
                                              color: theme?.textColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: task.priority == 'tinggi'
                                          ? const Color(0xFFFEF2F2)
                                          : (task.priority == 'sedang'
                                                ? const Color(0xFFFFFBEB)
                                                : const Color(0xFFECFDF5)),
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      border: Border.all(
                                        color: task.priority == 'tinggi'
                                            ? const Color(0xFFFECACA)
                                            : (task.priority == 'sedang'
                                                  ? const Color(0xFFFDE68A)
                                                  : const Color(0xFFA7F3D0)),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                        left: 8.0,
                                        top: 4.0,
                                        bottom: 4.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            Icons.flag_outlined,
                                            size: 16.0,
                                            color: task.priority == 'tinggi'
                                                ? const Color(0xFFDC2626)
                                                : (task.priority == 'sedang'
                                                      ? const Color(0xFFD97706)
                                                      : const Color(
                                                          0xFF059669,
                                                        )),
                                          ),
                                          Text(
                                            task.priority,
                                            style: TextStyle(
                                              color: task.priority == 'tinggi'
                                                  ? const Color(0xFFDC2626)
                                                  : (task.priority == 'sedang'
                                                        ? const Color(
                                                            0xFFD97706,
                                                          )
                                                        : const Color(
                                                            0xFF059669,
                                                          )),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          width: 10,
                          child: PopupMenuButton<String>(
                            color: Colors.white,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(16.0),
                              ),
                            ),
                            icon: const Icon(Icons.more_vert),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _showAddTaskModal(context, task: task);
                              } else if (value == 'delete') {
                                _deleteTask(task);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, color: Colors.blueAccent),
                                    SizedBox(width: 5),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.redAccent),
                                    SizedBox(width: 5),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}