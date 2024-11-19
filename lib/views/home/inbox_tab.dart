import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/service_locator.dart';
import 'package:google_fonts/google_fonts.dart';

class InboxTab extends ConsumerStatefulWidget {
  const InboxTab({super.key});

  @override
  ConsumerState<InboxTab> createState() => _InboxTabState();
}

class _InboxTabState extends ConsumerState<InboxTab> {
  @override
  Widget build(BuildContext context) {
  final chatroomstream = ref.watch(chatroomStreamProvider);
  print(chatroomstream.value);

    return SafeArea(
        child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Messages',
              style:
                  GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 16),
            ),
            ElevatedButton(onPressed: ()async{
              ref.read(messageRepositoryProvider).sendMessage('PR6efiUdngUzfoS7hO1AOHf7GI13', 'testing message');
            }, child: Text('send message'))
          ],
        ),
      ),
    ));
  }
}
