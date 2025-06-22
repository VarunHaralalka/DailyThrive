import 'package:flutter/material.dart';
import 'package:daily_thrive/dailyPlanner/constant.dart';

class ToDoListCard extends StatefulWidget {
  final String text;
  final double height;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onDelete; // Optional delete callback

  const ToDoListCard({
    super.key,
    required this.text,
    this.height = 100.0,
    this.margin = const EdgeInsets.all(10.0),
    this.padding = const EdgeInsets.all(10.0),
    this.onDelete,
  });

  @override
  ToDoListCardState createState() => ToDoListCardState();
}

class ToDoListCardState extends State<ToDoListCard> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      margin: widget.margin,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFB993FF), Color(0xFF8CA6DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: <Widget>[
            // Animated Checkbox
            Transform.scale(
              scale: 1.5,
              child: Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                activeColor: Colors.deepPurple,
                checkColor: Colors.white,
              ),
            ),
            const SizedBox(width: 14.0),
            // Task Text with strikethrough if checked
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: kBodyTextStyle.copyWith(
                  decoration: isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  color: isChecked ? Colors.black38 : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
                child: Text(widget.text,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 8.0),
            // Delete button (shows only if callback provided)
            if (widget.onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                tooltip: 'Delete task',
                onPressed: widget.onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
