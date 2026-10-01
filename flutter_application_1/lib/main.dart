import 'package:flutter/material.dart';
import 'textfield.dart';
import 'button.dart';

void main() {
  runApp(const MeuAplicativo());
}

class MeuAplicativo extends StatelessWidget {
  const MeuAplicativo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simulador Financeiro',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const TelaFinanceira(),
    );
  }
}

class TelaFinanceira extends StatefulWidget {
  const TelaFinanceira({super.key});

  @override
  State<TelaFinanceira> createState() => _TelaFinanceiraState();
}

class _TelaFinanceiraState extends State<TelaFinanceira> {
  final valorInicialController = TextEditingController();
  final aporteMensalController = TextEditingController();
  final taxaJurosController = TextEditingController();
  final quantidadeMesesController = TextEditingController();
  final metaFinanceiraController = TextEditingController();

  double montanteFinal = 0;
  double totalInvestido = 0;
  double lucro = 0;
  double valorFaltante = 0;

  String situacaoMeta = '';
  String perfilFinanceiro = '';

  void calcular() {
    if (valorInicialController.text.isEmpty ||
        aporteMensalController.text.isEmpty ||
        taxaJurosController.text.isEmpty ||
        quantidadeMesesController.text.isEmpty ||
        metaFinanceiraController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preencha todos os campos'),
        ),
      );
      return;
    }

    double valorInicial =
        double.tryParse(valorInicialController.text.replaceAll(',', '.')) ?? 0;

    double aporteMensal =
        double.tryParse(aporteMensalController.text.replaceAll(',', '.')) ?? 0;

    double taxa =
        double.tryParse(taxaJurosController.text.replaceAll(',', '.')) ?? 0;

    double meses =
        double.tryParse(quantidadeMesesController.text.replaceAll(',', '.')) ??
            0;

    double meta =
        double.tryParse(metaFinanceiraController.text.replaceAll(',', '.')) ??
            0;

    if (valorInicial < 0 ||
        aporteMensal < 0 ||
        taxa < 0 ||
        meses <= 0 ||
        meta < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Valores inválidos'),
        ),
      );
      return;
    }

    double taxaMensal = taxa / 100;

    double novoMontante =
        valorInicial * ((1 + taxaMensal) * (1 + taxaMensal)).toDouble();

    novoMontante = valorInicial *
        _potencia(
          1 + taxaMensal,
          meses,
        );

    double novoTotalInvestido =
        valorInicial + (aporteMensal * meses);

    double novoLucro = novoMontante - novoTotalInvestido;

    String novaSituacao;
    double novoValorFaltante;

    if (novoMontante >= meta) {
      novaSituacao = 'Meta alcançada';
      novoValorFaltante = 0;
    } else {
      novoValorFaltante = meta - novoMontante;
      novaSituacao =
          'Faltam R\$ ${novoValorFaltante.toStringAsFixed(2)} para atingir a meta';
    }

    String novoPerfil;

    if (taxa < 0.5) {
      novoPerfil = 'Conservador';
    } else if (taxa <= 1.5) {
      novoPerfil = 'Moderado';
    } else {
      novoPerfil = 'Agressivo';
    }

    setState(() {
      montanteFinal = novoMontante;
      totalInvestido = novoTotalInvestido;
      lucro = novoLucro;
      valorFaltante = novoValorFaltante;
      situacaoMeta = novaSituacao;
      perfilFinanceiro = novoPerfil;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulação realizada com sucesso'),
      ),
    );
  }

  double _potencia(double base, double expoente) {
    double resultado = 1;

    for (int i = 0; i < expoente.toInt(); i++) {
      resultado *= base;
    }

    return resultado;
  }

  void limparTudo() {
    valorInicialController.clear();
    aporteMensalController.clear();
    taxaJurosController.clear();
    quantidadeMesesController.clear();
    metaFinanceiraController.clear();

    setState(() {
      montanteFinal = 0;
      totalInvestido = 0;
      lucro = 0;
      valorFaltante = 0;
      situacaoMeta = '';
      perfilFinanceiro = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados removidos com sucesso'),
      ),
    );
  }

  void carregarExemplo() {
    valorInicialController.text = '1000';
    aporteMensalController.text = '500';
    taxaJurosController.text = '1.2';
    quantidadeMesesController.text = '24';
    metaFinanceiraController.text = '30000';

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dados de exemplo carregados'),
      ),
    );
  }

  void mostrarDialogoLimpar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Limpar dados'),
          content: const Text(
            'O que você deseja fazer?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('CANCELAR'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                limparTudo();
              },
              child: const Text('LIMPAR TUDO'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                carregarExemplo();
              },
              child: const Text('CARREGAR EXEMPLO'),
            ),
          ],
        );
      },
    );
  }

  Widget resultado(String titulo, String valor) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Flexible(
              child: Text(
                valor,
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    valorInicialController.dispose();
    aporteMensalController.dispose();
    taxaJurosController.dispose();
    quantidadeMesesController.dispose();
    metaFinanceiraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulador Financeiro'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Simulação de Investimento',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

          CustomTextField(
  label: 'Valor Inicial',
  controller: valorInicialController,
),

CustomTextField(
  label: 'Aporte Mensal',
  controller: aporteMensalController,
),

CustomTextField(
  label: 'Taxa de Juros (%)',
  controller: taxaJurosController,
),

CustomTextField(
  label: 'Quantidade de Meses',
  controller: quantidadeMesesController,
),

CustomTextField(
  label: 'Meta Financeira',
  controller: metaFinanceiraController,
),

const SizedBox(height: 5),

CustomButton(
  texto: 'CALCULAR',
  onPressed: calcular,
),

const SizedBox(height: 10),

CustomButton(
  texto: 'LIMPAR DADOS',
  onPressed: mostrarDialogoLimpar,
),

            const SizedBox(height: 25),

            if (situacaoMeta.isNotEmpty) ...[
              const Text(
                'RESULTADOS',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              resultado(
                'Montante Final',
                'R\$ ${montanteFinal.toStringAsFixed(2)}',
              ),

              resultado(
                'Total Investido',
                'R\$ ${totalInvestido.toStringAsFixed(2)}',
              ),

              resultado(
                'Lucro',
                'R\$ ${lucro.toStringAsFixed(2)}',
              ),

              resultado(
                'Situação da Meta',
                situacaoMeta,
              ),

              resultado(
                'Perfil Financeiro',
                perfilFinanceiro,
              ),
            ],
          ],
        ),
      ),
    );
  }
}