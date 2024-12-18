import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:folio/core/app_exception.dart';
import 'package:folio/core/service_locator.dart';
import 'package:folio/models/portfolio_model.dart';
import 'package:folio/views/create_portfolio_tabs/add_location_tab.dart';
import 'package:folio/views/create_portfolio_tabs/choose_service_screen.dart';
import 'package:folio/views/create_portfolio_tabs/input_experience_screen.dart';
import 'package:folio/views/create_portfolio_tabs/more_details_screen.dart';
import 'package:folio/widgets/account_item_widget.dart';
import 'package:folio/widgets/delete_account_dialog.dart';
import 'package:folio/widgets/verify_password_dialog.dart';
import 'package:google_fonts/google_fonts.dart';

class ManagePortfolioScreen extends ConsumerStatefulWidget {
  final PortfolioModel portfolioModel;
  const ManagePortfolioScreen({super.key, required this.portfolioModel});

  @override
  ConsumerState<ManagePortfolioScreen> createState() =>
      _ManagePortfolioScreenState();
}

class _ManagePortfolioScreenState extends ConsumerState<ManagePortfolioScreen> {
  bool _isLoading = false;
  String newService = "";
  int? newYears;
  int? newMonths;
  String newDetails = "";
  String? newAddress;
  double? newLatitude;
  double? newLongitude;

  void _showServiceSelectionDialog(BuildContext context) {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext dialogContext) {
        // Changed to dialogContext
        return StatefulBuilder(
          // Wrap Dialog in StatefulBuilder
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog.fullscreen(
              child: Scaffold(
                appBar: AppBar(
                  title: null,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ChooseService(
                            onServiceSelected: (service) {
                              setDialogState(() {
                                // Use setDialogState
                                newService = service;
                              });
                            },
                            initialService: widget.portfolioModel.service,
                            title: 'Update the service you offer!',
                            subTitle: 'Choose what best fits your work.',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if (newService == widget.portfolioModel.service ||
                                newService.isEmpty) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    showCloseIcon: true,
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      'Please choose the service you offer.',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              Navigator.pop(context);
                            } else {
                              setDialogState(() {
                                // Use setDialogState
                                _isLoading = true;
                              });

                              try {
                                await ref
                                    .read(portfolioRepositoryProvider)
                                    .updatePortfolio(
                                        fields: {'service': newService});

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                      showCloseIcon: true,
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                        e is AppException
                                            ? e.message
                                            : 'Error updating your portfolio. Try again later.',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  setDialogState(() {
                                    // Use setDialogState
                                    _isLoading = false;
                                  });
                                }
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: _isLoading ? Colors.grey[400] :
                                Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    strokeWidth: 5,
                                  ),
                                )
                              : Text(
                                  'Update',
                                  style: GoogleFonts.inter(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showExperienceUpdateDialog(BuildContext context) {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext dialogContext) {
        // Changed to dialogContext
        return StatefulBuilder(
          // Wrap Dialog in StatefulBuilder
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog.fullscreen(
              child: Scaffold(
                appBar: AppBar(
                  title: null,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: InputExperience(
                          onExperienceEntered: (year, month) {
                            setState(() {
                              newYears = year;
                              newMonths = month;
                            });
                          },
                          initialYears: widget.portfolioModel.years,
                          initialMonths: widget.portfolioModel.months,
                          title: 'Update your experience',
                          subTitle: 'Be as accurate as possible!',
                        )),
                        ElevatedButton(
                          onPressed: () async {
                            if (newYears == widget.portfolioModel.years &&
                                newMonths == widget.portfolioModel.months) {
                              Navigator.pop(context);
                            } else {
                              setDialogState(() {
                                // Use setDialogState
                                _isLoading = true;
                              });

                              try {
                                await ref
                                    .read(portfolioRepositoryProvider)
                                    .updatePortfolio(fields: {
                                  'years': newYears,
                                  'months': newMonths
                                });

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                      showCloseIcon: true,
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                        e is AppException
                                            ? e.message
                                            : 'Error updating your portfolio. Try again later.',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  setDialogState(() {
                                    // Use setDialogState
                                    _isLoading = false;
                                  });
                                }
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: _isLoading ? Colors.grey[400] :
                                Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    strokeWidth: 5,
                                  ),
                                )
                              : Text(
                                  'Update',
                                  style: GoogleFonts.poppins(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDetailsUpdateDialog(BuildContext context) {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext dialogContext) {
        // Changed to dialogContext
        return StatefulBuilder(
          // Wrap Dialog in StatefulBuilder
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog.fullscreen(
              child: Scaffold(
                appBar: AppBar(
                  title: null,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                            child: MoreDetailsScreen(
                          onDetailsEntered: (details) {
                            setState(() {
                              newDetails = details;
                            });
                          },
                          initialDetails: widget.portfolioModel.details,
                          title: 'Update your work details!',
                          subTitle:
                              'What would potential clients like to know?',
                        )),
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (newDetails == widget.portfolioModel.details) {
                                Navigator.pop(context);
                              } else {
                                setDialogState(() {
                                  // Use setDialogState
                                  _isLoading = true;
                                });

                                try {
                                  await ref
                                      .read(portfolioRepositoryProvider)
                                      .updatePortfolio(fields: {
                                    'details': newDetails,
                                  });

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor:
                                            Theme.of(context).colorScheme.error,
                                        showCloseIcon: true,
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                          e is AppException
                                              ? e.message
                                              : 'Error updating your portfolio. Try again later.',
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setDialogState(() {
                                      // Use setDialogState
                                      _isLoading = false;
                                    });
                                  }
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                               backgroundColor: _isLoading ? Colors.grey[400] :
                                Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    height: 25,
                                    width: 25,
                                    child: CircularProgressIndicator(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      strokeWidth: 5,
                                    ),
                                  )
                                : Text(
                                    'Update',
                                    style: GoogleFonts.poppins(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showLocationUpdateDialog(BuildContext context) {
    showDialog(
      useSafeArea: false,
      context: context,
      builder: (BuildContext dialogContext) {
        // Changed to dialogContext
        return StatefulBuilder(
          // Wrap Dialog in StatefulBuilder
          builder: (BuildContext context, StateSetter setDialogState) {
            return Dialog.fullscreen(
              child: Scaffold(
                appBar: AppBar(
                  title: null,
                  automaticallyImplyLeading: false,
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 30,
                    ),
                  ),
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: AddLocationTab(onAddressChosen: (String? address, double? latitude, double? longitude){
                            setState(() {
                              newAddress = address;
                              newLatitude = latitude;
                              newLongitude = longitude;
                            });
                          }, title: "Update your business's location.", subtitle: "Others won't be able to see this",)
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            if ((newAddress != null  && widget.portfolioModel.address == newAddress) || 
    (newLatitude != null && newLongitude != null && 
     widget.portfolioModel.latAndLong?['latitude'] == newLatitude && 
     widget.portfolioModel.latAndLong?['longitude'] == newLongitude))
                            {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    showCloseIcon: true,
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                      'Please choose a new address.',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              Navigator.pop(context);
                            } else if(newAddress != null && newLatitude != null && newLongitude != null){
                              setDialogState(() {
                                // Use setDialogState
                                _isLoading = true;
                              });

                              try {
                                await ref
                                    .read(portfolioRepositoryProvider)
                                    .updatePortfolio(
                                        fields: {'address': newAddress, 'latAndLong': {'latitude': newLatitude, 'longitude': newLongitude}});

                                if (context.mounted) {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                      showCloseIcon: true,
                                      behavior: SnackBarBehavior.floating,
                                      content: Text(
                                        e is AppException
                                            ? e.message
                                            : 'Error updating your portfolio. Try again later.',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (context.mounted) {
                                  setDialogState(() {
                                    // Use setDialogState
                                    _isLoading = false;
                                  });
                                }
                              }
                            }
                          },
                          style: TextButton.styleFrom(
                             backgroundColor: _isLoading ? Colors.grey[400] :
                                Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  height: 25,
                                  width: 25,
                                  child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    strokeWidth: 5,
                                  ),
                                )
                              : Text(
                                  'Update',
                                  style: GoogleFonts.inter(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Portfolio',
            style:
                GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            accountItem(
                title: 'Service',
                context: context,
                value: widget.portfolioModel.service,
                onTap: () => {_showServiceSelectionDialog(context)}),
            const SizedBox(
              height: 12,
            ),
            accountItem(
                title: 'Experience',
                context: context,
                value: widget.portfolioModel.getFormattedTotalExperience(),
                onTap: () => {_showExperienceUpdateDialog(context)}),
            const SizedBox(
              height: 12,
            ),
            accountItem(
                title: 'Details',
                context: context,
                value: widget.portfolioModel.details,
                onTap: () => {_showDetailsUpdateDialog(context)}),
                const SizedBox(
              height: 12,
            ),
            accountItem(
                title: 'Location',
                context: context,
                value: '${widget.portfolioModel.address}',
                onTap: () => {_showLocationUpdateDialog(context)})
          ],
        ),
      )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        child: TextButton(
            style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (context) => DeleteDialog(
                      title: 'Portfolio',
                      onPressed: () {
                        verifyPasswordDialog(context, 'Verify Password', "Please verify your password before deleting your portfolio.\n\nWe need to make sure it's you!",
                            (password) async {
                          try {
                            await ref
                                .watch(userRepositoryProvider)
                                .reauthenticateUser(password);

                            await ref
                                .watch(portfolioRepositoryProvider)
                                .deletePortfolio();
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (route) => false);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    showCloseIcon: true,
                                    behavior: SnackBarBehavior.floating,
                                    content: Text(
                                        e is AppException
                                            ? e.message
                                            : 'Portfolio deletion failed.',
                                        style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary))),
                              );
                            }
                          }
                        });
                      }));
            },
            child: Text(
              'DELETE PORTFOLIO',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )),
      ),
    );
  }
}
