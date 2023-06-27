import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ignore: must_be_immutable
class RadiusSlider extends StatefulWidget {
  double sliderValue;
  final Function(double value) onChanged;
  RadiusSlider({
    super.key,
    required this.sliderValue,
    required this.onChanged,
  });

  @override
  State<RadiusSlider> createState() => _RadiusSliderState();
}

class _RadiusSliderState extends State<RadiusSlider> {
  final radiusController = TextEditingController();
  @override
  void initState() {
    super.initState();
    radiusController.text = widget.sliderValue.round().toString() + ' m';
  }

  @override
  void dispose() {
    radiusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: TextField(
            controller: radiusController,
            style: TextStyle(color: Colors.black),
            textCapitalization: TextCapitalization.sentences,
            cursorColor: Color.fromARGB(255, 252, 139, 26),
            decoration: new InputDecoration(
              contentPadding: EdgeInsets.all(10),
              isCollapsed: true,
              enabled: false,
              labelText: 'Radius',
              labelStyle: TextStyle(
                color: Color.fromARGB(255, 104, 104, 104),
                fontSize: 15,
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Color.fromARGB(255, 252, 139, 26),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2,
                  color: Color.fromARGB(255, 252, 139, 26),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: 8,
            ),
            child: SliderTheme(
                data: SliderThemeData(
                    overlayShape: SliderComponentShape.noOverlay),
                child: Slider(
                  min: 25.0,
                  max: 275.0,
                  thumbColor: Color.fromARGB(255, 252, 139, 26),
                  activeColor: Color.fromARGB(255, 252, 139, 26),
                  inactiveColor: Color.fromARGB(255, 255, 231, 208),
                  value: widget.sliderValue,
                  divisions: 10,
                  label: '${widget.sliderValue.round()}',
                  onChanged: (value) {
                    setState(() {
                      widget.sliderValue = value;
                      radiusController.text = value.round().toString() + ' m';
                    });
                    widget.onChanged(value);
                  },
                )),
          ),
        ),
      ],
    );
  }
}
