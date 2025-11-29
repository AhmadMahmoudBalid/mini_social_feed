import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../cubit/posts_cubit.dart';
import '../../data/models/post_model.dart';

class CreatePostPage extends StatefulWidget {
  final PostModel? post;
  final PostsCubit postsCubit;

  const CreatePostPage({super.key, this.post, required this.postsCubit});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final List<String> _mediaPaths = [];
  final List<int> _removeMediaIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _titleController.text = widget.post!.title;
      _contentController.text = widget.post!.content;
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _mediaPaths.addAll(result.files.map((file) => file.path!).toList());
      });
    }
  }

  void _removeMedia(int index) {
    setState(() {
      _mediaPaths.removeAt(index);
    });
  }

  void _removeExistingMedia(int mediaId) {
    setState(() {
      if (_removeMediaIds.contains(mediaId)) {
        _removeMediaIds.remove(mediaId);
      } else {
        _removeMediaIds.add(mediaId);
      }
    });
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.post != null) {
        // تحديث المنشور
        widget.postsCubit.updatePost(
          id: widget.post!.id,
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          mediaPaths: _mediaPaths,
          removeMediaIds: _removeMediaIds,
        );
      } else {
        // إنشاء منشور جديد
        widget.postsCubit.createPost(
          title: _titleController.text.trim(),
          content: _contentController.text.trim(),
          mediaPaths: _mediaPaths,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostsCubit, PostsState>(
      bloc: widget.postsCubit,
      listener: (context, state) {
        if (state is PostsActionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        } else if (state is PostsActionSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.post != null ? 'Edit Post' : 'Create Post'),
          centerTitle: true,
          actions: [
            BlocBuilder<PostsCubit, PostsState>(
              bloc: widget.postsCubit,
              builder: (context, state) {
                return IconButton(
                  icon: state is PostsActionLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check),
                  onPressed: state is PostsActionLoading ? null : _submit,
                );
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 6,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter content';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // الوسائط المختارة
                if (_mediaPaths.isNotEmpty) ...[
                  const Text(
                    'Selected Media:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _mediaPaths.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: FileImage(File(_mediaPaths[index])),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => _removeMedia(index),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // الوسائط الحالية (للتعديل فقط)
                if (widget.post != null && widget.post!.media.isNotEmpty) ...[
                  const Text(
                    'Current Media:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.post!.media.length,
                      itemBuilder: (context, index) {
                        final media = widget.post!.media[index];
                        final isRemoved = _removeMediaIds.contains(media.id);

                        return Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: isRemoved
                                    ? Border.all(color: Colors.red, width: 3)
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: media.mediaType == 'image'
                                    ? Image.network(
                                        media.url,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Icon(
                                                  Icons.error,
                                                  size: 40,
                                                ),
                                              );
                                            },
                                      )
                                    : Container(
                                        color: Colors.grey[300],
                                        child: const Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.videocam, size: 40),
                                            SizedBox(height: 8),
                                            Text('Video'),
                                          ],
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 16,
                              child: GestureDetector(
                                onTap: () => _removeExistingMedia(media.id),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: isRemoved ? Colors.grey : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isRemoved ? Icons.undo : Icons.close,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // زر اختيار الوسائط
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _pickFiles,
                    icon: const Icon(Icons.attach_file),
                    label: const Text(
                      'Add Media',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}
