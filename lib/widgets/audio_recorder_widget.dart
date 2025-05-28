import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class AudioPicker extends StatefulWidget {
  final Function(File file) onFilePicked;

  AudioPicker({required this.onFilePicked});

  @override
  _AudioPickerState createState() => _AudioPickerState();
}

class _AudioPickerState extends State<AudioPicker> {
  File? _selectedFile;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null) {
      final file = File(result.files.single.path!);
      setState(() {
        _selectedFile = file;
      });
      widget.onFilePicked(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: Icon(Icons.audio_file),
              label: Text('Select Audio File'),
            ),
            SizedBox(width: 16),
            if (_selectedFile != null)
              Expanded(
                child: Text(
                  _selectedFile!.path.split('/').last,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
        if (_selectedFile != null)
          Container(
            margin: EdgeInsets.only(top: 8),
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('File selected: ${_selectedFile!.path.split('/').last}'),
          ),
      ],
    );
  }
}