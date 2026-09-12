import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:lala_ai/utils/app_toast.dart';
import 'package:lala_ai/utils/common_widget.dart';
import 'package:lala_ai/utils/extensions.dart';
import 'package:lala_ai/utils/theme/color_constant.dart';
import 'package:lala_ai/utils/theme/text_style.dart';

class MessageComposer extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isLoading;
  final VoidCallback onSend;
  final VoidCallback? onStop;
  final VoidCallback? onAttachmentTap;

  const MessageComposer({
    super.key,
    required this.controller,
    this.focusNode,
    required this.isLoading,
    required this.onSend,
    this.onStop,
    this.onAttachmentTap,
  });

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  late final FocusNode _effectiveFocusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _effectiveFocusNode = widget.focusNode ?? FocusNode();
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_onTextChanged);
    _effectiveFocusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final hasContent = widget.controller.text.trim().isNotEmpty;
    if (hasContent != _hasText) {
      setState(() => _hasText = hasContent);
    }
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _effectiveFocusNode.removeListener(_onFocusChanged);
    if (widget.focusNode == null) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  void _openVoiceInputSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ComposerVoiceSheet(
        onSpeechResult: (spokenText) {
          widget.controller.text = spokenText;
          widget.controller.selection = TextSelection.fromPosition(
            TextPosition(offset: spokenText.length),
          );
          _onTextChanged();
          Navigator.pop(context);
          AppToast.success("Voice transcribed successfully!");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: CC.background,
        border: Border(
          top: BorderSide(
            color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
              decoration: BoxDecoration(
                color: CC.surface,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: CC.isDark
                        ? Colors.black.withValues(alpha: 0.35)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Auto-expanding Multiline Text Field
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _effectiveFocusNode,
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.newline,
                        cursorColor: CC.primary,
                        style: TS.body(color: CC.textPrimary).copyWith(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: "Ask Lala Ai anything...",
                          hintStyle: TS.body(color: CC.textSecondary.withValues(alpha: 0.7)).copyWith(fontSize: 15),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ),
                  ),

                  6.width,

                  // Microphone Button for Voice Input
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: _openVoiceInputSheet,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.mic_none_rounded,
                            color: CC.textSecondary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),

                  4.width,

                  // Send or Stop Circular Action Button
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: widget.isLoading
                        ? GestureDetector(
                            onTap: widget.onStop,
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: CC.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: CC.error, width: 1.5),
                              ),
                              child: Center(
                                child: Icon(Icons.stop_rounded, color: CC.error, size: 18),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: _hasText ? widget.onSend : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _hasText
                                    ? CC.primary
                                    : CC.isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : Colors.black.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                                boxShadow: _hasText
                                    ? [
                                        BoxShadow(
                                          color: CC.primary.withValues(alpha: 0.35),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.arrow_upward_rounded,
                                  color: _hasText
                                      ? Colors.white
                                      : CC.textSecondary.withValues(alpha: 0.5),
                                  size: 19,
                                ),
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

// ── Voice Input & Speech Sheet Widget ────────────────────────────────────────
class _ComposerVoiceSheet extends StatefulWidget {
  final ValueChanged<String> onSpeechResult;

  const _ComposerVoiceSheet({required this.onSpeechResult});

  @override
  State<_ComposerVoiceSheet> createState() => _ComposerVoiceSheetState();
}

class _ComposerVoiceSheetState extends State<_ComposerVoiceSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  bool _isListening = false;
  bool _userActiveListening = true;
  String _accumulatedText = '';
  String _currentSessionWords = '';
  double _soundLevel = 0.0;

  String get _fullTranscript {
    final accumulated = _accumulatedText.trim();
    final current = _currentSessionWords.trim();
    if (accumulated.isNotEmpty && current.isNotEmpty) {
      return "$accumulated $current";
    }
    return accumulated.isNotEmpty ? accumulated : current;
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize(
        onError: (errorNotification) {
          debugPrint("SpeechToText Error: ${errorNotification.errorMsg}");
          if (_userActiveListening && mounted) {
            // Auto restart stream on transient pause/error
            Future.delayed(const Duration(milliseconds: 300), () {
              if (_userActiveListening && mounted) _startListening();
            });
          }
        },
        onStatus: (status) {
          debugPrint("SpeechToText Status: $status");
          if (status == 'done' || status == 'notListening') {
            if (_currentSessionWords.trim().isNotEmpty) {
              _accumulatedText = _accumulatedText.isEmpty
                  ? _currentSessionWords.trim()
                  : "$_accumulatedText ${_currentSessionWords.trim()}";
              _currentSessionWords = '';
            }
            if (_userActiveListening && mounted) {
              // Auto-restart continuous listening so long paragraphs keep dictating
              Future.delayed(const Duration(milliseconds: 250), () {
                if (_userActiveListening && mounted) _startListening();
              });
            } else if (mounted) {
              setState(() {
                _isListening = false;
              });
            }
          } else if (status == 'listening' && mounted) {
            setState(() {
              _isListening = true;
            });
          }
        },
      );
      if (_speechEnabled) {
        _userActiveListening = true;
        _startListening();
      } else {
        if (mounted) setState(() {});
      }
    } catch (e) {
      if (mounted) setState(() {});
    }
  }

  void _startListening() async {
    if (!_speechEnabled || !_userActiveListening) return;
    _currentSessionWords = '';
    await _speechToText.listen(
      onResult: (result) {
        if (mounted && result.recognizedWords.isNotEmpty) {
          setState(() {
            _currentSessionWords = result.recognizedWords;
          });
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: false,
        listenMode: ListenMode.dictation,
      ),
      onSoundLevelChange: (level) {
        if (mounted) {
          setState(() {
            _soundLevel = level;
          });
        }
      },
    );
    if (mounted) {
      setState(() {
        _isListening = true;
      });
    }
  }

  void _stopListening() async {
    _userActiveListening = false;
    await _speechToText.stop();
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _toggleListening() {
    if (_isListening || _userActiveListening) {
      _stopListening();
    } else {
      _userActiveListening = true;
      _startListening();
    }
  }

  @override
  void dispose() {
    _userActiveListening = false;
    _speechToText.stop();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transcript = _fullTranscript;
    final displayText = transcript.isNotEmpty
        ? "\"$transcript\""
        : (_isListening
            ? "Listening... Speak now"
            : (_speechEnabled
                ? "Tap microphone to speak"
                : "Initializing speech recognition..."));

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          color: CC.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(
            color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: CC.stroke,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            20.height,

            // Pulsing Mic Sphere
            GestureDetector(
              onTap: _toggleListening,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final soundBoost = (_soundLevel.clamp(-10.0, 10.0) + 10.0) / 20.0 * 0.12;
                  final scale = _isListening ? 1.0 + (_pulseController.value * 0.14) + soundBoost : 1.0;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (_isListening ? CC.primary : CC.grey).withValues(
                              alpha: 0.14 * (_isListening ? (1 - _pulseController.value * 0.4) : 0.5),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: _isListening
                                ? [
                                    CC.tealSubtle,
                                    CC.primary.withValues(alpha: 0.3),
                                  ]
                                : [
                                    CC.surface,
                                    CC.background,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: _isListening ? CC.primary : CC.stroke,
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                          color: _isListening ? CC.primary : CC.textSecondary,
                          size: 36,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            18.height,

            Text(
              _isListening ? "Listening to your voice..." : "Voice Speech Input",
              style: TS.sectionTitle(color: CC.textPrimary, fontSize: 18),
            ),
            6.height,
            Text(
              _isListening
                  ? "Speak your video topic, hook request, or title idea"
                  : "Tap the mic icon above to start speaking",
              textAlign: TextAlign.center,
              style: TS.caption(color: CC.textSecondary).copyWith(fontSize: 12),
            ),
            18.height,

            // Live real-time speech preview bubble
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              constraints: const BoxConstraints(minHeight: 52),
              decoration: BoxDecoration(
                color: CC.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: CC.stroke.withValues(alpha: CC.isDark ? 0.35 : 0.6),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isListening ? Icons.graphic_eq_rounded : Icons.mic_off_rounded,
                    color: _isListening ? CC.primary : CC.textSecondary,
                    size: 20,
                  ),
                  10.width,
                  Expanded(
                    child: Text(
                      displayText,
                      style: TS.bodySmall(color: CC.textPrimary).copyWith(
                        fontStyle: transcript.isNotEmpty ? FontStyle.normal : FontStyle.italic,
                        fontWeight: transcript.isNotEmpty ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            24.height,

            // Quick speech actions
            Row(
              children: [
                Expanded(
                  child: CW.commonBtn(
                    title: "Cancel",
                    isOutlined: true,
                    height: 46,
                    onTap: () {
                      _stopListening();
                      Navigator.pop(context);
                    },
                  ),
                ),
                12.width,
                Expanded(
                  child: CW.commonBtn(
                    title: "Use Voice Prompt",
                    height: 46,
                    onTap: () {
                      _stopListening();
                      final finalPrompt = _fullTranscript.trim();
                      if (finalPrompt.isNotEmpty) {
                        widget.onSpeechResult(finalPrompt);
                      } else {
                        AppToast.info("Please speak into microphone first");
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
