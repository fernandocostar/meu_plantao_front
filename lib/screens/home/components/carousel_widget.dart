import 'package:flutter/material.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:intl/intl.dart';
import 'carousel_page_indicator.dart';
import '../edit_shift/edit_shift_page.dart'; // Import the PageIndicator widget
import '../../../service/shift_service.dart';
import '../../common/components/auto_close_dialog.dart';

class CarouselWidget extends StatefulWidget {
  final List<dynamic> events;
  final Color primaryColor;
  final VoidCallback onShiftUpdated; // Add this callback

  CarouselWidget({
    required this.events,
    required this.primaryColor,
    required this.onShiftUpdated, // Initialize it in the constructor
  });

  @override
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _currentIndex = 0;

  Future<void> _deleteShift(dynamic shift) async {
    try {
      final ShiftService shiftService = ShiftService();
      await shiftService.deleteShift(shift['id']);
    } catch (e) {
      // Handle error, e.g., show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Falha ao deletar plantao. Tente novamente: $e')),
      );
    }
    setState(() {
      widget.events.remove(shift);
    });
    AutoCloseDialog.show(context, 'Plantao deletado com sucesso');
    widget.onShiftUpdated();
  }

  void _showDeleteConfirmationDialog(BuildContext context, dynamic shift) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Confirmar Exclusão",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Text(
                  "Tem certeza que deseja excluir esse plantão?",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .grey[300], // Light grey background// Text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        "Cancelar",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        _deleteShift(shift); // Call the delete method
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.red, // Red background for delete
                        textStyle:
                            TextStyle(color: Colors.white), // White text color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: Text(
                        "Deletar",
                        style: TextStyle(fontSize: 16, color: Colors.white),
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
            height: 250, // Card height
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
            String formattedStartTime =
                DateFormat('dd/MM/yyyy HH:mm').format(startTime);
            String formattedDuration =
                "${duration.inHours}h ${duration.inMinutes % 60}m";
            double value = shift['value'];
            String location = shift['location'];

            return LayoutBuilder(
              builder: (context, constraints) {
                double cardWidth =
                    constraints.maxWidth * 0.9; // Adjust width as needed

                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10.0),
                  width: cardWidth,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    elevation: 4,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment
                                .end, // Aligns both icons to the right
                            children: [
                              Text(
                                "Detalhes do plantao:",
                                style: TextStyle(
                                  fontSize: 20,
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
                                child: Icon(Icons.edit, color: Colors.grey),
                              ),
                              SizedBox(
                                  width:
                                      20), // Controls the spacing between the icons
                              InkWell(
                                onTap: () {
                                  _showDeleteConfirmationDialog(context, shift);
                                },
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Início: $formattedStartTime",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Duração: $formattedDuration",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Valor: R\$${value.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Local: $location",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[800],
                            ),
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
        SizedBox(height: 10),
        PageIndicator(
          itemCount: widget.events.length,
          currentIndex: _currentIndex,
          activeColor: widget.primaryColor,
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
