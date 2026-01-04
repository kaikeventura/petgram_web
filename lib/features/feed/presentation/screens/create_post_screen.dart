import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petgram_web/features/feed/presentation/providers/create_post_provider.dart';
import 'package:petgram_web/features/pet/providers/pet_context_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _captionController = TextEditingController();
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(createPostProvider.notifier).resetState());
  }

  Future<void> _pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CreatePostState>(createPostProvider, (previous, next) {
      if (next.status == CreatePostStatus.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicação criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
      if (next.status == CreatePostStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Ocorreu um erro.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    final createPostState = ref.watch(createPostProvider);
    final isLoading = createPostState.status == CreatePostStatus.loading;
    final currentPet = ref.watch(petContextProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Publicação'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: (_imageFile == null || isLoading)
                ? null
                : () {
                    ref.read(createPostProvider.notifier).createPost(
                          image: _imageFile!,
                          caption: _captionController.text,
                        );
                  },
            child: isLoading
                ? const CircularProgressIndicator()
                : const Text('Publicar'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (currentPet != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: currentPet.avatarUrl != null
                          ? NetworkImage(currentPet.avatarUrl!)
                          : null,
                      child: currentPet.avatarUrl == null
                          ? Text(currentPet.name[0].toUpperCase())
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      currentPet.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            if (_imageFile == null)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.add_a_photo, size: 50),
                  ),
                ),
              )
            else
              kIsWeb
                  ? Image.network(_imageFile!.path, height: 250)
                  : Image.file(File(_imageFile!.path), height: 250),
            const SizedBox(height: 20),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Escreva uma legenda...',
                border: InputBorder.none,
              ),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
