import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../bloc/wallet_cubit.dart';
import '../bloc/wallet_state.dart';
import '../../../home/presentation/widgets/balance_card.dart';

class TopUpScreen extends StatefulWidget {
  final double initialBalance;

  const TopUpScreen({super.key, required this.initialBalance});

  @override
  State<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  late double _currentBalance; // Usamos un estado interno para el saldo
  double _selectedAmount = 3000;
  final _customAmountController = TextEditingController();
  bool _isCustomAmount = false;

  final List<double> _predefinedAmounts = [3000, 10000, 5000];

  @override
  void initState() {
    super.initState();
    _currentBalance = widget.initialBalance;
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  void _onAmountSelected(double amount) {
    setState(() {
      _selectedAmount = amount;
      _isCustomAmount = false;
      _customAmountController.clear();
    });
  }

  void _onCustomAmountChanged(String value) {
    final amount = double.tryParse(value) ?? 0;
    setState(() {
      _selectedAmount = amount;
      _isCustomAmount = true;
    });
  }

  Future<void> _launchMercadoPago(BuildContext context, String url) async {
    final theme = Theme.of(context);
    try {
      await launchUrl(
        Uri.parse(url),
        customTabsOptions: CustomTabsOptions(
          colorSchemes: CustomTabsColorSchemes.defaults(
            toolbarColor: AppColors.primary,
          ),
          shareState: CustomTabsShareState.on,
          urlBarHidingEnabled: true,
          showTitle: true,
          closeButton: CustomTabsCloseButton(
            icon: CustomTabsCloseButtonIcons.back,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir el navegador')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WalletCubit(
        walletRepository: context.read<WalletRepository>(),
      ),
      child: BlocListener<WalletCubit, WalletState>(
        listener: (context, state) {
          if (state is WalletSuccess) {
            _launchMercadoPago(context, state.initPoint);
          } else if (state is WalletError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
            );
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Cargar saldo",
              style: GoogleFonts.nunito(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
          ),
          body: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {

              double currentBalance = _currentBalance;
              if (authState is Authenticated) {
                currentBalance = authState.user.balance ?? _currentBalance;
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    BalanceCard(balance: currentBalance),
                    const SizedBox(height: 32),
                    
                    Text(
                      "Elegí un monto",
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _predefinedAmounts.map((amount) {
                        final bool isSelected = !_isCustomAmount && _selectedAmount == amount;
                        return _buildAmountCard(amount, isSelected);
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    Text(
                      "O ingresá otro monto",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: _customAmountController,
                      keyboardType: TextInputType.number,
                      onChanged: _onCustomAmountChanged,
                      decoration: InputDecoration(
                        hintText: "\$ 0",
                        filled: true,
                        fillColor: AppColors.inputFieldBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    
                    const SizedBox(height: 32),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B1EA).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF00B1EA).withOpacity(0.1)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF00B1EA)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text.rich(
                              TextSpan(
                                text: "La carga se procesa a través de ",
                                children: [
                                  TextSpan(
                                    text: "Mercado Pago",
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w800),
                                  ),
                                ],
                              ),
                              style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    BlocBuilder<WalletCubit, WalletState>(
                      builder: (context, walletState) {
                        final bool isLoading = walletState is WalletLoading;
                        return ElevatedButton(
                          onPressed: isLoading || _selectedAmount <= 0 
                            ? null 
                            : () {
                              if (authState is Authenticated) {
                                context.read<WalletCubit>().prepareTopUp(
                                  authState.user.id, 
                                  _selectedAmount
                                );
                              }
                            },
                          child: isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text("Cargar \$ ${_selectedAmount.toStringAsFixed(0)}"),
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(double amount, bool isSelected) {
    return GestureDetector(
      onTap: () => _onAmountSelected(amount),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.26,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.black.withOpacity(0.05),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "\$ ${amount.toStringAsFixed(0)}",
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            if (amount == 5000)
              Text(
                "Última carga",
                style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
