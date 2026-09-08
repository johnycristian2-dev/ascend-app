import 'package:flutter/material.dart';
import '../theme/ink.dart';
import '../theme/type.dart';

/// Rótulo caixa-alta espaçado — a voz visual do app.
class Lbl extends StatelessWidget {
  final String text;
  final Color color;
  final double size;
  final double tracking;
  const Lbl(this.text,
      {this.color = Ink_.text3, this.size = 10, this.tracking = 0.2, super.key});

  @override
  Widget build(BuildContext c) => Text(text,
      style: T.label(size: size, color: color, tracking: tracking));
}

/// Card padrão: superfície, borda de 1 px, raio 4.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? bg;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool dashed;
  const Panel({
    required this.child,
    this.padding = const EdgeInsets.all(13),
    this.bg,
    this.borderColor,
    this.onTap,
    this.dashed = false,
    super.key,
  });

  @override
  Widget build(BuildContext c) {
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: bg ?? Ink_.surface,
        border: Border.all(color: borderColor ?? Ink_.border),
        borderRadius: r4,
      ),
      child: child,
    );
    return onTap == null
        ? box
        : InkWell(onTap: onTap, borderRadius: r4, child: box);
  }
}

class Bar extends StatelessWidget {
  final double pct;
  final Color color;
  final double height;
  const Bar(this.pct, {this.color = Ink_.green, this.height = 3, super.key});

  @override
  Widget build(BuildContext c) => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(2)),
        child: LinearProgressIndicator(
          value: pct.clamp(0, 1),
          minHeight: height,
          backgroundColor: Ink_.border,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      );
}

/// Rótulo + valor, para grades de estatística.
class Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double size;
  const Stat(this.label, this.value,
      {this.color = Ink_.textStrong, this.size = 21, super.key});

  @override
  Widget build(BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Lbl(label, color: Ink_.dim, size: 9),
          const SizedBox(height: 5),
          Text(value, style: T.num(size: size, color: color)),
        ],
      );
}

/// Botão retangular. `primary` usa a superfície mais clara do protótipo.
class Btn extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool primary;
  final Color? ink;
  final Color? bg;
  final Color? border;
  const Btn(this.label,
      {this.onTap, this.primary = false, this.ink, this.bg, this.border, super.key});

  @override
  Widget build(BuildContext c) => InkWell(
        onTap: onTap,
        borderRadius: r4,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: bg ?? (primary ? Ink_.raised : Ink_.surface),
            border: Border.all(color: border ?? (primary ? Ink_.borderRaised : Ink_.border)),
            borderRadius: r4,
          ),
          child: Center(
            child: Lbl(label,
                color: ink ?? (primary ? Ink_.text : Ink_.text2),
                size: 11,
                tracking: 0.16),
          ),
        ),
      );
}

/// Campo de formulário somente-leitura, para telas de demonstração.
class Field extends StatelessWidget {
  final String label;
  final String value;
  const Field({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext c) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Lbl(label, color: Ink_.dim, size: 9),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Ink_.surface,
              border: Border.all(color: Ink_.borderInput),
              borderRadius: r4,
            ),
            child: Text(value, style: T.body(size: 11, color: Ink_.text)),
          ),
        ],
      );
}

/// Cabeçalho de tela: voltar + título + informação à direita.
class ScreenBar extends StatelessWidget {
  final String title;
  final String? sub;
  final String? trailing;
  final VoidCallback? onBack;
  const ScreenBar(this.title, {this.sub, this.trailing, this.onBack, super.key});

  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (onBack != null) ...[
              InkWell(
                onTap: onBack,
                borderRadius: r4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Ink_.surface,
                    border: Border.all(color: Ink_.border),
                    borderRadius: r4,
                  ),
                  child: const Icon(Icons.arrow_back, size: 15, color: Ink_.text),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Lbl(title, color: Ink_.text, size: 17, tracking: 0.16),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(sub!, style: T.body(size: 10, color: Ink_.text3)),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Ink_.border),
                  borderRadius: r4,
                ),
                child: Lbl(trailing!, color: Ink_.dim, size: 9, tracking: 0.16),
              ),
          ],
        ),
      );
}

/// Linha rótulo/valor usada em listas de detalhe.
class Row2 extends StatelessWidget {
  final String label;
  final String value;
  final Color ink;
  const Row2(this.label, this.value, {this.ink = Ink_.text, super.key});

  @override
  Widget build(BuildContext c) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Lbl(label.toUpperCase(), color: Ink_.dim, size: 9),
            const SizedBox(width: 12),
            Expanded(
              child: Text(value,
                  textAlign: TextAlign.right, style: T.body(size: 10, color: ink)),
            ),
          ],
        ),
      );
}

/// Chip de estado (RECOMENDADO, RISCO, TÉCNICO…).
class Tag extends StatelessWidget {
  final String label;
  final Color ink;
  const Tag(this.label, this.ink, {super.key});

  @override
  Widget build(BuildContext c) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: ink.withValues(alpha: .5)),
          borderRadius: r4,
        ),
        child: Lbl(label, color: ink, size: 8, tracking: 0.16),
      );
}
