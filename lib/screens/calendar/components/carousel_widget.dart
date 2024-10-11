import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:intl/intl.dart';
import 'carousel_page_indicator.dart';
import '../../edit_shift/edit_shift_page.dart';
import '../../../service/shift_service.dart';
import '../../common/components/auto_close_dialog.dart';
import '../../shift_passing/shift_passing_page.dart';

class CarouselWidget extends StatefulWidget {
  final List<dynamic> events;
  final Color primaryColor;
  final VoidCallback onShiftUpdated;

  CarouselWidget({
    required this.events,
    required this.primaryColor,
    required this.onShiftUpdated,
  });

  @override
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _currentIndex = 0;

  // Constants for styling
  static const double _fontSize = 16.0;
  static const double _headerFontSize = 18.0;
  static const double _buttonFontSize = 14.0;
  static const double _padding = 16.0;
  static const double _cardElevation = 4.0;
  static const double _borderRadius = 16.0;
  static const double _dialogBorderRadius = 10.0;
  static const double _buttonBorderRadius = 8.0;
  static const double _deleteButtonBorderRadius = 5.0;
  static const Color _cancelButtonColor = Color(0xFFE0E0E0); // Equivalent to Colors.grey[300]
  static const Color _deleteButtonColor = Color(0xFFFF0000); // Equivalent to Colors.red
  static const Color _whiteColor = Color(0xFFFFFFFF); // Equivalent to Colors.white
  static const Color _blackColor = Color(0xFF000000); // Equivalent to Colors.black
  static const Color _black87Color = Color(0xDD000000); // Equivalent to Colors.black87
  static const Color _greyColor = Color(0xFF9E9E9E); // Equivalent to Colors.grey

  Future<void> _deleteShift(dynamic shift) async {
    try {
      final ShiftService shiftService = ShiftService();
      await shiftService.deleteShift(shift['id']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao deletar plantão. Tente novamente')),
      );
      return;
    }
    setState(() {
      widget.events.remove(shift);
    });
    AutoCloseDialog.show(context, 'Plantão deletado com sucesso');
    widget.onShiftUpdated();
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic shift) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_dialogBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Confirmar Exclusão",
                  style: TextStyle(
                    fontSize: _headerFontSize,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Tem certeza que deseja excluir esse plantão?",
                  style: TextStyle(
                    fontSize: _fontSize,
                    color: _black87Color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cancelButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_buttonBorderRadius),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(fontSize: _buttonFontSize, color: _blackColor),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        _deleteShift(shift); // Call the delete method
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _deleteButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_deleteButtonBorderRadius),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      child: const Text(
                        "Deletar",
                        style: TextStyle(fontSize: _buttonFontSize, color: _whiteColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 220, // Card height
            enableInfiniteScroll: false,
            viewportFraction: 1.1, // Adjust width as needed
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.events.map((shift) {
            DateTime startTime = DateTime.parse(shift['startTime']);
            DateTime endTime = DateTime.parse(shift['endTime']);
            Duration duration = endTime.difference(startTime);
            String formattedStartTime = DateFormat('dd/MM/yyyy HH:mm').format(startTime);
            String formattedDuration = "${duration.inHours}h ${duration.inMinutes % 60}m";
            double value = shift['value'];
            String location = shift['location']['name'];

            return LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth = constraints.maxWidth * 0.9; // Adjust width as needed

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  width: cardWidth,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(_borderRadius),
                    ),
                    elevation: _cardElevation,
                    color: _whiteColor,
                    child: Padding(
                      padding: const EdgeInsets.all(_padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end, // Aligns both icons to the right
                            children: [
                              Text(
                                "Detalhes do plantão:",
                                style: TextStyle(
                                  fontSize: _headerFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: widget.primaryColor,
                                ),
                              ),
                              Spacer(), // Pushes the text to the left and icons to the right
                              InkWell(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditShiftPage(
                                        shift: shift,
                                        onSave: () => print("Save"),
                                        onCancel: () => print("Cancel"),
                                      ),
                                    ),
                                  );

                                  if (result == true) {
                                    widget.onShiftUpdated();
                                  }
                                },
                                child: Icon(Icons.edit, color: _greyColor),
                              ),
                              SizedBox(width: 20), // Controls the spacing between the icons
                              InkWell(
                                onTap: () {
                                  _showDeleteConfirmationDialog(context, shift);
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: _greyColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Início: $formattedStartTime",
                            style: TextStyle(
                              fontSize: _fontSize,
                              color: _black87Color,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Duração: $formattedDuration",
                            style: TextStyle(
                              fontSize: _fontSize,
                              color: _black87Color,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Valor: R\$${value.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: _fontSize,
                              color: _black87Color,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Altere a linha abaixo para adicionar o ícone de encaminhamento
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: _greyColor),
                                  SizedBox(width: 8.0),
                                  Text(
                                    location,
                                    style: TextStyle(
                                      fontSize: _fontSize,
                                      color: _black87Color,
                                    ),
                                  ),
                                ],
                              ),
                              // Novo Ícone de Encaminhamento
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShiftPassingPage(shift: shift, onSave: (){},), //TODO: Implement onSave
                                    ),
                                  );
                                },
                                child: Icon(Icons.send, color: _greyColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 0),
        PageIndicator(
          itemCount: widget.events.length,
          currentIndex: _currentIndex,
          activeColor: widget.primaryColor,
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
