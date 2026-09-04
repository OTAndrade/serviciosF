import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../home/presentation/widgets/ineed_drawer.dart';

enum _TipoAyuda {
  solicitante,
  ofertante,
}

class AyudaScreen extends StatefulWidget {
  const AyudaScreen({super.key});

  @override
  State<AyudaScreen> createState() => _AyudaScreenState();
}

class _AyudaScreenState extends State<AyudaScreen> {
  // Igual que fragment_ayuda.xml: la ayuda del solicitante aparece
  // inicialmente al abrir la pantalla.
  _TipoAyuda _seleccion = _TipoAyuda.solicitante;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const INeedDrawer(),
      appBar: AppBar(
        title: const Text(AppStrings.ayuda),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      _AyudaButton(
                        label: 'Como Solicitar un Servicio',
                        selected: _seleccion == _TipoAyuda.solicitante,
                        onPressed: () {
                          setState(() {
                            _seleccion = _TipoAyuda.solicitante;
                          });
                        },
                      ),
                      _AyudaButton(
                        label: 'Como atender una solicitud',
                        selected: _seleccion == _TipoAyuda.ofertante,
                        onPressed: () {
                          setState(() {
                            _seleccion = _TipoAyuda.ofertante;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _seleccion == _TipoAyuda.solicitante
                            ? const _AyudaSolicitante(
                                key: ValueKey('solicitante'),
                              )
                            : const _AyudaOfertante(
                                key: ValueKey('ofertante'),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AyudaButton extends StatelessWidget {
  const _AyudaButton({
    required this.label,
    required this.selected,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return selected
        ? FilledButton(
            onPressed: onPressed,
            child: Text(label),
          )
        : OutlinedButton(
            onPressed: onPressed,
            child: Text(label),
          );
  }
}

class _AyudaSolicitante extends StatelessWidget {
  const _AyudaSolicitante({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AyudaContenido(
      sections: [
        _AyudaSection(
          title: 'Como solicitar un servicio?',
          paragraphs: [
            'Puedes solicitar un servicio desde i-need. '
                'Para hacerlo, realiza lo siguiente:',
          ],
          steps: [
            'En la parte superior tienes la opción de Buscar (Lupa), '
                'atravéz de esta puedes seleccionar el servicio que necesitas, '
                'escribe o selecciona de la lista.',
            'Selecciona una especialidad de la lista de especialidades.',
            'En la parte inferior tienes una barra que te permite definir '
                'el radio de búsqueda, define la distancia en la cual se '
                'buscarán todos los especialistas que se encuentren dentro '
                'del radio definido.',
            'Como resultado puedes tener uno o más alfileres, presiona sobre '
                'el alfiler para observar la información del especialista.',
            'Presiona el botón Solicitar para enviar a cada especialista una '
                'solicitud de atención.',
            'Si deseas realizar una nueva selección, modifica la distancia o '
                'selecciona otra especialidad.',
            'Para ver las solicitudes realizadas presiona el botón Ver '
                'Solicitudes.',
            'Cuando algún especialista respoda a tu solicitud, la aplicación '
                'te mostrará una notificación, mediante el botón ver '
                'solicitudes podrás ver las respuestas.',
            'Haciendo Click sobre cada alfiler podrás ver la información de '
                'cada profesional o técnico que te responda Ej: precio, años '
                'de experiencia, teléfono, etc.',
          ],
        ),
        _AyudaSection(
          title: 'Que tengo que esperar después de Solicitar un Servicio?',
          steps: [
            'Luego de presionar el botón Solicitar todos los especialistas '
                'seleccionado reciben una solicitud.',
            'A medida que los especialistas vayan atendiendo la solicitud, '
                'los alfileres irán cambiando a una imagen con un signo de '
                'admiración (!) al medio.',
          ],
        ),
        _AyudaSection(
          title: 'Como confirmo una solicitud atendida?',
          steps: [
            'Cuando uno o mas alfileres esten con el signo de admiración (!), '
                'usted podrá ver la información del especialista y la hora '
                'que este propone para la cita haciendo click sobre el '
                'alfiler.',
            'Haciendo click por segunda vez podrá confirmar la cita con el '
                'especialista seleccionado.',
            'Luego de confirmar una cita las solicitudes elaboradas '
                'desapareceran y quedará la solicitud confirmada con un '
                'alfiler con un signo de check al medio.',
          ],
        ),
      ],
    );
  }
}

class _AyudaOfertante extends StatelessWidget {
  const _AyudaOfertante({super.key});

  @override
  Widget build(BuildContext context) {
    return const _AyudaContenido(
      sections: [
        _AyudaSection(
          title: 'Como atender una solicitud de servicio?',
          paragraphs: [
            'En la pantalla principal se mostrarán todas las solicitudes '
                'atravéz de alfileres.',
            'Para atender una solicitudes deberá hacer lo siguiente:',
          ],
          steps: [
            'Haga click sobre el alfiler que quiere atender.',
            'Para atender la solicitud seleccionada haga click nuevamente '
                'como indica el texto del alfiler.',
            'Seleccione la hora en la cual propone la cita',
            'El alfiler cambiará de la imagen del medio a un signo de '
                'admiración (!).',
            'Cuando el solicitante confirme la cita, el alfiler cambiará la '
                'imagen del medio a un signo de check.',
          ],
        ),
      ],
    );
  }
}

class _AyudaContenido extends StatelessWidget {
  const _AyudaContenido({
    required this.sections,
    super.key,
  });

  final List<_AyudaSection> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < sections.length; index++) ...[
          _AyudaSectionView(section: sections[index]),
          if (index != sections.length - 1) const SizedBox(height: 26),
        ],
      ],
    );
  }
}

class _AyudaSection {
  const _AyudaSection({
    required this.title,
    this.paragraphs = const <String>[],
    this.steps = const <String>[],
  });

  final String title;
  final List<String> paragraphs;
  final List<String> steps;
}

class _AyudaSectionView extends StatelessWidget {
  const _AyudaSectionView({
    required this.section,
  });

  final _AyudaSection section;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (section.paragraphs.isNotEmpty) const SizedBox(height: 10),
        for (final paragraph in section.paragraphs) ...[
          Text(
            paragraph,
            style: textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 8),
        ],
        if (section.steps.isNotEmpty) const SizedBox(height: 2),
        for (var i = 0; i < section.steps.length; i++) ...[
          _StepRow(
            number: i + 1,
            text: section.steps[i],
          ),
          if (i != section.steps.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.number,
    required this.text,
  });

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '$number.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                ),
          ),
        ),
      ],
    );
  }
}
