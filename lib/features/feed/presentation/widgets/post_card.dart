import 'package:flutter/material.dart';
import 'package:petgram_web/features/feed/data/models/post_model.dart';

class PostCard extends StatelessWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Removido o shape para usar o padrão do tema
      // Removida a margem para ser controlada pelo ListView
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const CircleAvatar(
                  // Usando um placeholder, já que a URL da foto do autor não vem no feed
                  backgroundColor: Colors.grey,
                  radius: 20,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Text(
                  post.authorName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Imagem do Post
          Image.network(
            post.photoUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 400, // Altura fixa para consistência
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                height: 400,
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 400,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.error, color: Colors.red)),
              );
            },
          ),

          // Botões de Ação
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () { /* TODO */ },
                ),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () { /* TODO */ },
                ),
                const Spacer(),
              ],
            ),
          ),

          // Likes e Legenda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${post.likeCount} curtidas',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${post.authorName} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: post.caption),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
