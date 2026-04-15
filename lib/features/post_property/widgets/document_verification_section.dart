import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../constants/colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Field model: describes a single input field for a document type
// ─────────────────────────────────────────────────────────────────────────────
enum FieldType { text, number, date, dropdown }

class DocumentField {
  final String key;
  final String label;
  final String hint;
  final IconData icon;
  final FieldType type;
  final bool required;
  final List<String>? options; // for dropdown

  const DocumentField({
    required this.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.type = FieldType.text,
    this.required = false,
    this.options,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Per-document field definitions (researched for Nigerian property docs)
// ─────────────────────────────────────────────────────────────────────────────
final Map<String, List<DocumentField>> _documentFields = {
  // 1. Certificate of Occupancy -------------------------------------------------
  'Certificate of Occupancy (C of O)': [
    DocumentField(
      key: 'co_number',
      label: 'C of O Number *',
      hint: 'e.g., LAG/C-O/2023/00123',
      icon: Iconsax.document_text,
      required: true,
    ),
    DocumentField(
      key: 'file_number',
      label: 'File Number',
      hint: 'e.g., LND/FILE/2023/456',
      icon: Iconsax.folder_2,
    ),
    DocumentField(
      key: 'plot_number',
      label: 'Plot Number *',
      hint: 'e.g., Plot 25',
      icon: Iconsax.map,
      required: true,
    ),
    DocumentField(
      key: 'state_of_issue',
      label: 'State of Issue *',
      hint: 'e.g., Lagos State',
      icon: Iconsax.location,
      required: true,
    ),
    DocumentField(
      key: 'date_of_issue',
      label: 'Date of Issue *',
      hint: 'e.g., 15/03/2021',
      icon: Iconsax.calendar,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'issuing_ministry',
      label: 'Issuing Ministry / Authority',
      hint: 'e.g., Ministry of Lands, Lagos',
      icon: Iconsax.building,
    ),
  ],

  // 2. Deed of Assignment -------------------------------------------------------
  'Deed of Assignment': [
    DocumentField(
      key: 'registration_number',
      label: 'Registration Number *',
      hint: 'e.g., REG/DOA/2022/789',
      icon: Iconsax.document_text,
      required: true,
    ),
    DocumentField(
      key: 'grantor_name',
      label: "Grantor's (Seller's) Name *",
      hint: 'Full legal name of the seller',
      icon: Iconsax.user,
      required: true,
    ),
    DocumentField(
      key: 'grantee_name',
      label: "Grantee's (Buyer's) Name *",
      hint: 'Full legal name of the buyer',
      icon: Iconsax.user_tick,
      required: true,
    ),
    DocumentField(
      key: 'date_of_assignment',
      label: 'Date of Assignment *',
      hint: 'e.g., 10/06/2023',
      icon: Iconsax.calendar,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'land_registry',
      label: 'Land Registry Office',
      hint: 'e.g., Lagos State Land Registry, Alausa',
      icon: Iconsax.building_4,
    ),
    DocumentField(
      key: 'consideration',
      label: 'Consideration / Purchase Price (₦)',
      hint: 'e.g., 15000000',
      icon: Iconsax.wallet,
      type: FieldType.number,
    ),
  ],

  // 3. Rent Agreement -----------------------------------------------------------
  'Rent Agreement': [
    DocumentField(
      key: 'landlord_name',
      label: "Landlord's Full Name *",
      hint: 'e.g., Chukwuemeka Obi',
      icon: Iconsax.user,
      required: true,
    ),
    DocumentField(
      key: 'landlord_phone',
      label: "Landlord's Phone Number *",
      hint: 'e.g., 08012345678',
      icon: Iconsax.call,
      type: FieldType.number,
      required: true,
    ),
    DocumentField(
      key: 'rent_start_date',
      label: 'Rent Start Date *',
      hint: 'e.g., 01/01/2024',
      icon: Iconsax.calendar_1,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'rent_end_date',
      label: 'Rent End Date *',
      hint: 'e.g., 31/12/2024',
      icon: Iconsax.calendar_remove,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'annual_rent',
      label: 'Annual Rent Amount (₦) *',
      hint: 'e.g., 600000',
      icon: Iconsax.wallet_money,
      type: FieldType.number,
      required: true,
    ),
    DocumentField(
      key: 'agreement_number',
      label: 'Agreement / Reference Number',
      hint: 'e.g., RA/2024/001',
      icon: Iconsax.document_text,
    ),
  ],

  // 4. Authorization Letter -----------------------------------------------------
  'Authorization Letter': [
    DocumentField(
      key: 'authorizer_name',
      label: "Authorizer's Full Name *",
      hint: 'Name of the owner granting authorization',
      icon: Iconsax.user,
      required: true,
    ),
    DocumentField(
      key: 'authorizer_relationship',
      label: 'Relationship to Property Owner *',
      hint: 'e.g., Owner, Spouse, Sibling',
      icon: Iconsax.people,
      type: FieldType.dropdown,
      required: true,
      options: [
        'Property Owner',
        'Spouse',
        'Parent',
        'Sibling',
        'Legal Representative',
        'Company Director',
        'Other',
      ],
    ),
    DocumentField(
      key: 'date_issued',
      label: 'Date of Authorization *',
      hint: 'e.g., 20/02/2025',
      icon: Iconsax.calendar,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'authorized_purpose',
      label: 'Purpose of Authorization',
      hint: 'e.g., To list the property for sale',
      icon: Iconsax.note_text,
    ),
    DocumentField(
      key: 'notarized_by',
      label: 'Notarized / Witnessed By',
      hint: 'e.g., Commissioner for Oaths',
      icon: Iconsax.verify,
    ),
  ],

  // 5. Survey Plan --------------------------------------------------------------
  'Survey Plan': [
    DocumentField(
      key: 'survey_plan_number',
      label: 'Survey Plan Number *',
      hint: 'e.g., OG/SP/2020/00456',
      icon: Iconsax.document_text,
      required: true,
    ),
    DocumentField(
      key: 'surveyor_name',
      label: "Surveyor's Full Name *",
      hint: 'e.g., Engr. Adebayo Tunde',
      icon: Iconsax.user,
      required: true,
    ),
    DocumentField(
      key: 'surcon_number',
      label: 'SURCON Registration Number',
      hint: 'Surveyors Council of Nigeria reg. no.',
      icon: Iconsax.verify,
    ),
    DocumentField(
      key: 'date_of_survey',
      label: 'Date of Survey *',
      hint: 'e.g., 05/09/2020',
      icon: Iconsax.calendar,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'surveyor_general_office',
      label: "Surveyor-General's Office (State)",
      hint: 'e.g., Ogun State Surveyor-General',
      icon: Iconsax.building,
    ),
    DocumentField(
      key: 'beacon_numbers',
      label: 'Beacon / Pillar Numbers',
      hint: 'e.g., BK1234, BK1235',
      icon: Iconsax.location,
    ),
  ],

  // 6. Governor's Consent -------------------------------------------------------
  "Governor's Consent": [
    DocumentField(
      key: 'consent_number',
      label: "Governor's Consent Number *",
      hint: 'e.g., GC/LAG/2022/00789',
      icon: Iconsax.document_text,
      required: true,
    ),
    DocumentField(
      key: 'state',
      label: 'State *',
      hint: 'e.g., Ogun State',
      icon: Iconsax.location,
      required: true,
    ),
    DocumentField(
      key: 'date_issued',
      label: 'Date Issued *',
      hint: 'e.g., 11/04/2022',
      icon: Iconsax.calendar,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'file_number',
      label: 'File Number',
      hint: 'e.g., LND/FILE/2022/112',
      icon: Iconsax.folder_2,
    ),
    DocumentField(
      key: 'related_co_number',
      label: 'Related C of O Number',
      hint: 'C of O this consent is based on',
      icon: Iconsax.link,
    ),
  ],

  // 7. Land Purchase Receipt ----------------------------------------------------
  'Land Purchase Receipt': [
    DocumentField(
      key: 'receipt_number',
      label: 'Receipt Number *',
      hint: 'e.g., LPR/2021/00345',
      icon: Iconsax.receipt_item,
      required: true,
    ),
    DocumentField(
      key: 'seller_name',
      label: "Seller's Full Name *",
      hint: 'e.g., Fatima Mohammed',
      icon: Iconsax.user,
      required: true,
    ),
    DocumentField(
      key: 'seller_phone',
      label: "Seller's Phone Number",
      hint: 'e.g., 08098765432',
      icon: Iconsax.call,
      type: FieldType.number,
    ),
    DocumentField(
      key: 'date_of_purchase',
      label: 'Date of Purchase *',
      hint: 'e.g., 15/07/2021',
      icon: Iconsax.calendar,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'amount_paid',
      label: 'Amount Paid (₦) *',
      hint: 'e.g., 5000000',
      icon: Iconsax.wallet,
      type: FieldType.number,
      required: true,
    ),
    DocumentField(
      key: 'witnesses',
      label: 'Witness Names',
      hint: 'e.g., Emeka Eze, Sarah Olu',
      icon: Iconsax.people,
    ),
  ],

  // 8. Building Approval --------------------------------------------------------
  'Building Approval': [
    DocumentField(
      key: 'approval_number',
      label: 'Approval Number *',
      hint: 'e.g., BA/LGA/2023/00112',
      icon: Iconsax.document_text,
      required: true,
    ),
    DocumentField(
      key: 'issuing_authority',
      label: 'Issuing Authority *',
      hint: 'e.g., Lagos State Physical Planning Authority',
      icon: Iconsax.building_4,
      required: true,
    ),
    DocumentField(
      key: 'date_of_approval',
      label: 'Date of Approval *',
      hint: 'e.g., 03/03/2023',
      icon: Iconsax.calendar,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'local_govt_area',
      label: 'Local Government Area',
      hint: 'e.g., Ikeja LGA',
      icon: Iconsax.location,
    ),
    DocumentField(
      key: 'approval_type',
      label: 'Approval Type',
      hint: 'e.g., Residential, Commercial',
      icon: Iconsax.category,
      type: FieldType.dropdown,
      options: [
        'Residential',
        'Commercial',
        'Mixed Use',
        'Industrial',
        'Other',
      ],
    ),
  ],

  // 9. Power of Attorney --------------------------------------------------------
  'Power of Attorney': [
    DocumentField(
      key: 'attorney_name',
      label: "Attorney's Full Name *",
      hint: 'Person granted power of attorney',
      icon: Iconsax.user,
      required: true,
    ),
    DocumentField(
      key: 'grantor_name',
      label: "Grantor's Full Name *",
      hint: 'Property owner granting the authority',
      icon: Iconsax.user_octagon,
      required: true,
    ),
    DocumentField(
      key: 'date_executed',
      label: 'Date Executed *',
      hint: 'e.g., 22/11/2023',
      icon: Iconsax.calendar,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'notarized_by',
      label: 'Notarized By *',
      hint: 'e.g., Commissioner for Oaths, High Court',
      icon: Iconsax.verify,
      required: true,
    ),
    DocumentField(
      key: 'poa_type',
      label: 'Type of Power of Attorney',
      hint: '',
      icon: Iconsax.document_filter,
      type: FieldType.dropdown,
      options: ['General', 'Special / Limited', 'Irrevocable', 'Other'],
    ),
    DocumentField(
      key: 'registration_number',
      label: 'Registration Number',
      hint: 'If registered at the Land Registry',
      icon: Iconsax.document_text,
    ),
  ],

  // 10. Deed of Gift ------------------------------------------------------------
  'Deed of Gift': [
    DocumentField(
      key: 'registration_number',
      label: 'Registration Number *',
      hint: 'e.g., REG/DOG/2022/045',
      icon: Iconsax.document_text,
      required: true,
    ),
    DocumentField(
      key: 'donor_name',
      label: "Donor's Full Name *",
      hint: 'Person giving the property as a gift',
      icon: Iconsax.user,
      required: true,
    ),
    DocumentField(
      key: 'donee_name',
      label: "Donee's Full Name *",
      hint: 'Person receiving the property',
      icon: Iconsax.user_tick,
      required: true,
    ),
    DocumentField(
      key: 'date_of_gift',
      label: 'Date of Gift Deed *',
      hint: 'e.g., 14/02/2022',
      icon: Iconsax.calendar,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'relationship',
      label: 'Relationship Between Donor & Donee',
      hint: 'e.g., Parent and Child',
      icon: Iconsax.people,
    ),
    DocumentField(
      key: 'land_registry',
      label: 'Land Registry Where Registered',
      hint: 'e.g., Abuja Land Registry, FCT',
      icon: Iconsax.building_4,
    ),
  ],

  // 11. Family Letter of Consent ------------------------------------------------
  'Family Letter of Consent': [
    DocumentField(
      key: 'family_name',
      label: 'Family / Compound Name *',
      hint: 'e.g., Adeyemi Family of Ile-Ife',
      icon: Iconsax.people,
      required: true,
    ),
    DocumentField(
      key: 'family_head_name',
      label: "Family Head's Full Name *",
      hint: 'e.g., Chief Adeyemi Babatunde',
      icon: Iconsax.user_octagon,
      required: true,
    ),
    DocumentField(
      key: 'family_head_phone',
      label: "Family Head's Phone Number *",
      hint: 'e.g., 07011223344',
      icon: Iconsax.call,
      type: FieldType.number,
      required: true,
    ),
    DocumentField(
      key: 'date_of_consent',
      label: 'Date of Consent Letter *',
      hint: 'e.g., 01/05/2023',
      icon: Iconsax.calendar,
      type: FieldType.date,
      required: true,
    ),
    DocumentField(
      key: 'num_signatories',
      label: 'Number of Signatories',
      hint: 'e.g., 5',
      icon: Iconsax.pen_add,
      type: FieldType.number,
    ),
    DocumentField(
      key: 'witnessed_by',
      label: 'Witnessed / Stamped By',
      hint: 'e.g., Ogun State Ministry of Lands',
      icon: Iconsax.verify,
    ),
  ],
};

// ─────────────────────────────────────────────────────────────────────────────
// Helper: short description shown under each document option
// ─────────────────────────────────────────────────────────────────────────────
const Map<String, String> _documentDescriptions = {
  'Certificate of Occupancy (C of O)':
      'Govt-issued 99-year title. Strongest proof of ownership.',
  'Deed of Assignment':
      'Legal transfer of ownership from seller to buyer at the Land Registry.',
  'Rent Agreement': 'Landlord–tenant contract. Required for rental listings.',
  'Authorization Letter':
      'Written permission from the owner for you to list on their behalf.',
  'Survey Plan':
      'Licensed surveyor map showing land boundaries, approved by Surveyor-General.',
  "Governor's Consent":
      'Required for all subsequent land transactions after a C of O is issued.',
  'Land Purchase Receipt':
      'Proof of payment. Useful for unregistered land transactions.',
  'Building Approval':
      'Official planning authority approval for the building structure.',
  'Power of Attorney':
      'Legal authority granted to act on behalf of the property owner.',
  'Deed of Gift':
      'Document showing property transferred as a gift, registered at Land Registry.',
  'Family Letter of Consent':
      'Consent from family/compound head for family-owned/ancestral land.',
};

// ─────────────────────────────────────────────────────────────────────────────
// Main Widget
// ─────────────────────────────────────────────────────────────────────────────
class DocumentVerificationSection extends StatefulWidget {
  final Function(String) onDocumentSelected;
  final Function(Map<String, dynamic>)? onDocumentDataChanged;
  final String? selectedDocument;

  const DocumentVerificationSection({
    super.key,
    required this.onDocumentSelected,
    this.onDocumentDataChanged,
    this.selectedDocument,
  });

  @override
  State<DocumentVerificationSection> createState() =>
      _DocumentVerificationSectionState();
}

class _DocumentVerificationSectionState
    extends State<DocumentVerificationSection> {
  String? _selectedDocument;

  // Holds a TextEditingController for each field key of the selected doc
  final Map<String, TextEditingController> _controllers = {};

  // Holds dropdown values for dropdown fields
  final Map<String, String?> _dropdownValues = {};

  // Holds date values
  final Map<String, String> _dateValues = {};

  @override
  void initState() {
    super.initState();
    _selectedDocument = widget.selectedDocument;
    if (_selectedDocument != null) {
      _initControllersForDocument(_selectedDocument!);
    }
  }

  void _initControllersForDocument(String docType) {
    // Dispose old controllers
    for (final c in _controllers.values) {
      c.dispose();
    }
    _controllers.clear();
    _dropdownValues.clear();
    _dateValues.clear();

    final fields = _documentFields[docType] ?? [];
    for (final field in fields) {
      if (field.type == FieldType.dropdown) {
        _dropdownValues[field.key] = null;
      } else {
        _controllers[field.key] = TextEditingController();
      }
    }
  }

  Map<String, dynamic> getDocumentData() {
    final data = <String, dynamic>{'document_type': _selectedDocument ?? ''};
    _controllers.forEach((key, ctrl) {
      data[key] = ctrl.text.trim();
    });
    _dropdownValues.forEach((key, value) {
      data[key] = value ?? '';
    });
    _dateValues.forEach((key, value) {
      data[key] = value;
    });
    return data;
  }

  bool isValid() {
    if (_selectedDocument == null || _selectedDocument!.isEmpty) return false;
    final fields = _documentFields[_selectedDocument!] ?? [];
    for (final field in fields) {
      if (!field.required) continue;
      if (field.type == FieldType.dropdown) {
        if (_dropdownValues[field.key] == null ||
            _dropdownValues[field.key]!.isEmpty) {
          return false;
        }
      } else {
        final ctrl = _controllers[field.key];
        if (ctrl == null || ctrl.text.trim().isEmpty) return false;
      }
    }
    return true;
  }

  void _notifyParent() {
    widget.onDocumentDataChanged?.call(getDocumentData());
  }

  Future<void> _pickDate(String fieldKey) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: AppColors.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {
        _dateValues[fieldKey] = formatted;
        // also update the text controller for display
        if (_controllers.containsKey(fieldKey)) {
          _controllers[fieldKey]!.text = formatted;
        }
      });
      _notifyParent();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Info banner ──────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Iconsax.info_circle, size: 20, color: AppColors.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select ONE document type that proves your ownership. '
                  'Your property will be reviewed before going live.',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.accent,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Document Type Label ──────────────────────────────────────────────
        Text(
          'Document Type *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // ── Document List ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.greyLight),
          ),
          child: Column(
            children: _documentFields.keys.map((doc) {
              final isSelected = _selectedDocument == doc;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        // Deselect
                        _selectedDocument = null;
                        _initControllersForDocument('');
                        widget.onDocumentSelected('');
                      } else {
                        _selectedDocument = doc;
                        _initControllersForDocument(doc);
                        widget.onDocumentSelected(doc);
                      }
                    });
                    _notifyParent();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.success.withValues(alpha: 0.08)
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.success
                            : AppColors.greyLight,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.greyLight.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            isSelected
                                ? Iconsax.tick_circle
                                : Iconsax.document_text,
                            size: 20,
                            color: isSelected
                                ? AppColors.success
                                : AppColors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                doc,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.success
                                      : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _documentDescriptions[doc] ?? '',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Iconsax.tick_circle,
                            color: AppColors.success,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        // ── Dynamic Fields for selected document ─────────────────────────────
        if (_selectedDocument != null &&
            (_documentFields[_selectedDocument!]?.isNotEmpty ?? false)) ...[
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                  child: Row(
                    children: [
                      Icon(Iconsax.edit_2, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Fill in the details for: $_selectedDocument',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Fields
                ...(_documentFields[_selectedDocument!] ?? []).map((field) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                    child: _buildField(field),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Review notice
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.clock, size: 18, color: AppColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Your property will be reviewed within 24–48 hours after submission.',
                    style: TextStyle(fontSize: 12, color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── Field builder ────────────────────────────────────────────────────────────
  Widget _buildField(DocumentField field) {
    switch (field.type) {
      case FieldType.dropdown:
        return _buildDropdownField(field);
      case FieldType.date:
        return _buildDateField(field);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(DocumentField field) {
    _controllers.putIfAbsent(field.key, () => TextEditingController());

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controllers[field.key],
            keyboardType: field.type == FieldType.number
                ? TextInputType.number
                : TextInputType.text,
            onChanged: (_) => _notifyParent(),
            decoration: InputDecoration(
              hintText: field.hint,
              hintStyle: TextStyle(fontSize: 13, color: AppColors.grey),
              prefixIcon: Icon(field.icon, size: 18, color: AppColors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(DocumentField field) {
    _controllers.putIfAbsent(field.key, () => TextEditingController());

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => _pickDate(field.key),
            child: AbsorbPointer(
              child: TextField(
                controller: _controllers[field.key],
                decoration: InputDecoration(
                  hintText: field.hint,
                  hintStyle: TextStyle(fontSize: 13, color: AppColors.grey),
                  prefixIcon: Icon(field.icon, size: 18, color: AppColors.grey),
                  suffixIcon: Icon(
                    Iconsax.calendar_2,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(DocumentField field) {
    _dropdownValues.putIfAbsent(field.key, () => null);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.greyLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _dropdownValues[field.key],
            items: (field.options ?? [])
                .map(
                  (opt) => DropdownMenuItem(
                    value: opt,
                    child: Text(opt, style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() => _dropdownValues[field.key] = val);
              _notifyParent();
            },
            decoration: InputDecoration(
              hintText: 'Select an option',
              hintStyle: TextStyle(fontSize: 13, color: AppColors.grey),
              prefixIcon: Icon(field.icon, size: 18, color: AppColors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
            isExpanded: true,
            icon: Icon(Iconsax.arrow_down_1, color: AppColors.grey, size: 18),
            dropdownColor: AppColors.surface,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
