import 'dart:io';
import 'package:expenses_app/widgets/transaction_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './widgets/transaction_list.dart';
import './widgets/new_transaction.dart';
import './widgets/chart.dart';
import './models/transaction.dart';

// import 'package:flutter/services.dart';

void main(){
  // SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: 'Personal Expenses',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
          title: TextStyle(
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          button: TextStyle(color: Colors.white),
        ),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
            title: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),)
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {

  final List<Transaction> _userTransactions = [
    // Transaction(
    //   id: 't1',
    //   title: 'Sapatos',
    //   amount: 69.99,
    //   date: DateTime.now()
    // ),
    // Transaction(
    //   id: 't2',
    //   title: 'Comidinhas',
    //   amount: 129.99,
    //   date: DateTime.now()
    // ),
    
  ];

  bool _showChart = false;

  @override
  void initState(){
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    print(state);
  }

  @override
  dispose(){
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  List<Transaction> get _recentTransactions{
    return _userTransactions.where((tx) {
      return tx.date.isAfter(
        DateTime.now().subtract(
          Duration(days: 7),
        ),
      );
    }).toList();
  }

  void _addNewTransaction(String txTitle, double txAmount, DateTime chosenDate){
    final newTx = Transaction(
      title: txTitle,
      amount: txAmount,
      date: chosenDate,
      id: DateTime.now().toString(),
    );

    setState(() {
      _userTransactions.add(newTx);
    });
  }

  void _startAddNewTransaction(BuildContext ctx){
    showModalBottomSheet(
      context: ctx,
      builder: (_) {
        return GestureDetector(
          onTap: () {},
          child: NewTransaction(_addNewTransaction),
          behavior: HitTestBehavior.opaque,
        );
      },
    );
  }

  void _deleteTransaction(String id){
    setState(() {
      _userTransactions.removeWhere((tx) => tx.id == id);
      
      // _userTransactions.removeWhere((tx) {
      //   return tx.id == id;
      // });
    });
  }

  List<Widget> _buildLandscapeContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget){

    return [Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text('Show Chart', style: Theme.of(context).textTheme.title,),
        Switch.adaptive(
          activeColor: Theme.of(context).accentColor,
          value:_showChart, onChanged: (val) {
            setState(() {
              _showChart = val;
            });
          },
        ),
      ],
    ), _showChart ?
      Container(
          height: (mediaQuery.size.height
          - appBar.preferredSize.height
          - mediaQuery.padding.top)*0.3,
          child: Chart(_recentTransactions)
        )
        : txListWidget];
  }

  List <Widget> _buildPortraitContent(
    MediaQueryData mediaQuery,
    AppBar appBar,
    Widget txListWidget){

    return [Container(
      height: (mediaQuery.size.height
      - appBar.preferredSize.height
      - mediaQuery.padding.top)*0.3,
      child: Chart(_recentTransactions)
    ), txListWidget];
  }

  Widget _buildAppBar(){
    
    var appBarTitle = Text('Personal Expenses');

    return Platform.isIOS ?
    CupertinoNavigationBar(
      middle: appBarTitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          GestureDetector(
            child: Icon(CupertinoIcons.add),
            onTap: () => _startAddNewTransaction(context),
          )
        ],
      ),
    ) :
    AppBar(
        title: appBarTitle,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _startAddNewTransaction(context),
          )
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    var pctHeight = (isLandscape ? 0.85: 0.7);

    final PreferredSizeWidget appBar = _buildAppBar();

    //Widget for creating the transaction list. This variable was created to
    //avoid duplicating the code.

    final txListWidget = Container(
              height: (mediaQuery.size.height
              - appBar.preferredSize.height
              - mediaQuery.padding.top)*pctHeight,
              child: TransactionList(_userTransactions,_deleteTransaction)
      );

    final pageBody = SafeArea(child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (isLandscape) ..._buildLandscapeContent(mediaQuery,
            appBar,
            txListWidget),

            if (!isLandscape) ..._buildPortraitContent(mediaQuery,
            appBar,
            txListWidget),          
          ],
        ),
      ),
    );

    return Platform.isIOS ? CupertinoPageScaffold(
      child: pageBody,
      navigationBar: appBar,
    ) :
    Scaffold(
      appBar: appBar,
      body: pageBody,
      floatingActionButton: Platform.isIOS ? Container() : FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _startAddNewTransaction(context),
        ),
    );
  }
}
