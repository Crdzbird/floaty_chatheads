import 'dart:async';

import 'package:floaty_chatheads/floaty_chatheads.dart';
import 'package:flutter/material.dart';

import 'basic_controls.dart';
import 'received_header.dart';
import 'received_list.dart';

part 'home_page_state.dart';

/// Basic example: shows and closes the chathead, sends data both ways and
/// lists the messages received from the overlay.
final class HomePage extends StatefulWidget {
  /// Creates the basic example page.
  const factory HomePage({Key? key}) = HomePage._;

  const HomePage._({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
