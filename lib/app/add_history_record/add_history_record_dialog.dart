import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:livestock/app/add_history_record/widgets/add_animal_detail_header.dart';
import 'package:livestock/app/add_history_record/widgets/diagnosis_selection_widget.dart';
import 'package:livestock/app/add_history_record/widgets/health_status_selection_widget.dart';
import 'package:livestock/app/add_history_record/widgets/treatment_selection_widget.dart';
import 'package:livestock/app/animal_details/bloc/bloc.dart';
import 'package:livestock/src/ui/theming.dart';
import 'package:livestock/src/ui/widgets/livestock_primary_button.dart';

import 'bloc/bloc.dart';

class AddHistoryRecordDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddHistoryRecordDialogState();
}

class _AddHistoryRecordDialogState extends State<AddHistoryRecordDialog> {
  final _formKey = GlobalKey<FormState>();

  AddHistoryRecordBloc _addHistoryRecordBloc;
  AnimalDetailsBloc _animalDetailsBloc;
  TextEditingController _cageEditingController;

  @override
  void initState() {
    super.initState();

    _addHistoryRecordBloc = context.bloc<AddHistoryRecordBloc>();
    _animalDetailsBloc = context.bloc<AnimalDetailsBloc>();
    _cageEditingController = TextEditingController();
    _cageEditingController.addListener(_onCageNumberChanged);
    _cageEditingController.value = TextEditingValue(
      text: _animalDetailsBloc.state.cage?.toString() ?? '',
      selection: TextSelection.fromPosition(
        TextPosition(
            offset: _animalDetailsBloc.state.cage.toString().length ?? 0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20,
        ),
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
            ),
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: BlocListener<AddHistoryRecordBloc, AddHistoryRecordState>(
                listener: (context, state) {
                  if (state.isSaved) {
                    Navigator.of(context).pop();

                    _animalDetailsBloc.add(
                      UpdateDetails(
                        cage: state.cage,
                        currentHealthStatus: state.healthStatus,
                      ),
                    );
                  }
                },
                child: BlocBuilder<AddHistoryRecordBloc, AddHistoryRecordState>(
                  builder: (context, state) {
                    if (state.isSaved) {
                      return Container();
                    }

                    return Column(
                      children: <Widget>[
                        Expanded(
                          child: Form(
                            key: _formKey,
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  AddAnimalDetailHeader(
                                    onClose: () => Navigator.of(context).pop(),
                                  ),
                                  ..._buildDateRow(state),
                                  ..._buildHealthStatusSelectionRow(state),
                                  ..._buildDiagnosisSelectionRow(state),
                                  ..._buildTreatmentSelectionRow(state),
                                  ..._buildTreatmentEndDateRow(state),
                                ],
                              ),
                            ),
                          ),
                        ),
                        _buildBottomBar(state),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(AddHistoryRecordState state) {
    var saveAction = state.canSave
        ? () => context.bloc<AddHistoryRecordBloc>().add(
              SaveAnimalHistoryRecord(
                stateToSave: state,
              ),
            )
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Divider(),
        Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: LivestockPrimaryButton(
            text: 'Opslaan',
            onPressed: saveAction,
            icon: Icon(
              FontAwesomeIcons.plus,
              color: Colors.white,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildDateRow(AddHistoryRecordState state) {
    return <Widget>[
      Divider(),
      Padding(
        padding: const EdgeInsets.only(
          top: 15.0,
          bottom: 15.0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Datum',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 14, bottom: 18),
                  child: Text(
                    state.registrationDateDisplayValue,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Hok',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: TextField(
                    controller: _cageEditingController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          style: BorderStyle.solid,
                        ),
                      ),
                      contentPadding: const EdgeInsets.all(0),
                      counter: Container(),
                    ),
                    maxLength: 3,
                    maxLengthEnforced: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: kDefaultTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildDiagnosisSelectionRow(
      AddHistoryRecordState animalDetailState) {
    if (!animalDetailState.allowDiagnosisSelection) {
      return <Widget>[];
    }

    return _buildDialogRow(
      title: 'Diagnose',
      child: DiagnosisSelectionWidget(
        onChanged: (diagnosis) =>
            BlocProvider.of<AddHistoryRecordBloc>(context).add(
          UpdateDiagnosis(
            diagnosis: diagnosis,
            previousState: animalDetailState,
          ),
        ),
        selectedDiagnosis: animalDetailState.diagnosis,
      ),
    );
  }

  List<Widget> _buildHealthStatusSelectionRow(
      AddHistoryRecordState animalDetailState) {
    return _buildDialogRow(
      title: 'Gezondheidsstatus',
      child: HealthStatusSelectionWidget(
        onChanged: (healthStatus) =>
            BlocProvider.of<AddHistoryRecordBloc>(context).add(
          UpdateHealthStatus(
            healthStatus: healthStatus,
            previousState: animalDetailState,
          ),
        ),
        selectedHealthStatus: animalDetailState.healthStatus,
      ),
    );
  }

  List<Widget> _buildTreatmentEndDateRow(
    AddHistoryRecordState recordState,
  ) {
    if (!recordState.allowTreatmentSelection) {
      return <Widget>[];
    }

    return _buildDialogRow(
      title: 'Einddatum',
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            recordState.treatmentEndDateDisplayValue,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
          IconButton(
            onPressed: () => showDatePicker(
              context: context,
              initialDate: recordState.treatmentEndDate ?? DateTime.now(),
              firstDate: DateTime.now().subtract(Duration(days: 1)),
              lastDate: DateTime.now().add(Duration(days: 31)),
            ).then(
              (selectedDate) => _addHistoryRecordBloc.add(
                UpdateTreatmentEndDate(endDate: selectedDate),
              ),
            ),
            icon: Icon(FontAwesomeIcons.calendar),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTreatmentSelectionRow(AddHistoryRecordState recordState) {
    if (!recordState.allowTreatmentSelection) {
      return <Widget>[];
    }

    return _buildDialogRow(
      title: 'Behandeling',
      child: TreatmentSelectionWidget(
        onChanged: (treatment) =>
            BlocProvider.of<AddHistoryRecordBloc>(context).add(
          UpdateTreatment(
            treatment: treatment,
            previousState: recordState,
          ),
        ),
        selectedTreatment: recordState.treatment,
      ),
    );
  }

  List<Widget> _buildDialogRow({
    @required String title,
    @required Widget child,
  }) {
    return <Widget>[
      Divider(),
      Padding(
        padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15.0,
          ),
        ),
      ),
      Padding(padding: const EdgeInsets.only(bottom: 15.0), child: child),
    ];
  }

  @override
  void dispose() {
    _cageEditingController.dispose();
    super.dispose();
  }

  void _onCageNumberChanged() {
    _addHistoryRecordBloc.add(
      UpdateCageNumber(
        cage: _cageEditingController.text,
      ),
    );
  }
}
