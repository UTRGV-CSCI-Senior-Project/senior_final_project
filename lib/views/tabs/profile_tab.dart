import 'package:flutter/material.dart';
import 'package:folio/models/user_model.dart';

class ProfileTab extends StatelessWidget {
  final dynamic userModel;


const ProfileTab({
    super.key,
    required this.userModel,
  });
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: 
    Padding(padding: const EdgeInsets.all(20), child:Column(
      children: [Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(62),
                                child: userModel.profilePictureUrl != null
                                  ? Image.network(
                                      userModel.profilePictureUrl,
                                      width: 125,
                                      height: 125,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 125,
                                      height: 125,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                    ),
                              ),
                              const SizedBox(width: 16),
                              // Name and Service
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      userModel.fullName ?? userModel.username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )],
    ) ,)
    );
  }
}