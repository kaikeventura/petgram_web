import 'package:flutter/material.dart';

/// Widget base que aplica o efeito de brilho (Shimmer)
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  const ShimmerEffect({super.key, required this.child});

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                Color(0xFFE0E0E0), // Grey 300
                Color(0xFFF5F5F5), // Grey 100 (Brilho)
                Color(0xFFE0E0E0), // Grey 300
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Caixa cinza básica para montar os esqueletos
class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final bool isCircle;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0), // Cor base
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircle ? null : BorderRadius.circular(8),
      ),
    );
  }
}

/// Esqueleto específico para o Card de Post
class PostSkeleton extends StatelessWidget {
  const PostSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ShimmerEffect(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header (Avatar + Nome)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(
                children: [
                  SkeletonBox(width: 40, height: 40, isCircle: true),
                  SizedBox(width: 12),
                  SkeletonBox(width: 120, height: 16),
                ],
              ),
            ),
            // Imagem do Post
            const SkeletonBox(width: double.infinity, height: 400),
            // Ações (Botões)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
              child: Row(
                children: [
                  SkeletonBox(width: 24, height: 24), // Like
                  SizedBox(width: 16),
                  SkeletonBox(width: 24, height: 24), // Comment
                ],
              ),
            ),
            // Legenda e Curtidas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 80, height: 14), // Curtidas
                  SizedBox(height: 8),
                  SkeletonBox(width: double.infinity, height: 14), // Legenda linha 1
                  SizedBox(height: 4),
                  SkeletonBox(width: 200, height: 14), // Legenda linha 2
                  SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Esqueleto para o Grid de Fotos (Perfil)
class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 1.0,
        ),
        itemCount: 9, // Simula 9 fotos
        itemBuilder: (context, index) {
          return Container(color: const Color(0xFFE0E0E0));
        },
      ),
    );
  }
}

/// Esqueleto para o Header do Perfil
class ProfileHeaderSkeleton extends StatelessWidget {
  const ProfileHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBox(width: 80, height: 80, isCircle: true),
                const SizedBox(width: 20),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      SkeletonBox(width: 40, height: 40),
                      SkeletonBox(width: 40, height: 40),
                      SkeletonBox(width: 40, height: 40),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SkeletonBox(width: 150, height: 16),
            const SizedBox(height: 16),
            const SkeletonBox(width: double.infinity, height: 36),
          ],
        ),
      ),
    );
  }
}
