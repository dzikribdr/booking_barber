import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import '../../features/admin/domain/models/booking_model.dart';
import 'file_helper.dart';

class ExportUtils {
  static Future<void> exportToPdf(List<BookingModel> bookings, String filter) async {
    final pdf = pw.Document();
    
    final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm');
    final double totalRevenue = bookings.fold(0.0, (sum, b) => sum + (b.totalPrice ?? 0.0));
    final int totalBookings = bookings.length;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Financial Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.Text('BARBER 69', style: pw.TextStyle(fontSize: 18, color: PdfColors.grey700)),
                ]
              )
            ),
            pw.SizedBox(height: 10),
            pw.Text('Filter: $filter'),
            pw.Text('Generated: ${formatter.format(DateTime.now())}'),
            pw.SizedBox(height: 20),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
              children: [
                pw.Column(
                  children: [
                    pw.Text('Total Bookings', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
                    pw.Text('$totalBookings', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ]
                ),
                pw.Column(
                  children: [
                    pw.Text('Total Revenue', style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey)),
                    pw.Text('Rp ${totalRevenue.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  ]
                ),
              ]
            ),
            pw.SizedBox(height: 30),
            pw.Text('Transactions:', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 10),
            pw.TableHelper.fromTextArray(
              context: context,
              headers: ['ID', 'Date', 'Customer', 'Service', 'Barber', 'Status', 'Amount (Rp)'],
              data: bookings.map((b) {
                final customerName = b.customerName ?? 'Walk-in';
                final serviceName = b.service?.name ?? '-';
                final barberName = b.barber?.name ?? '-';
                final dateStr = formatter.format(b.bookingDate.toLocal());
                
                return [
                  b.id.substring(0, 8),
                  dateStr,
                  customerName,
                  serviceName,
                  barberName,
                  b.status,
                  (b.totalPrice ?? 0.0).toStringAsFixed(0),
                ];
              }).toList(),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await saveAndShareFile(bytes, 'Financial_Report_$filter.pdf');
  }

  static Future<void> exportToExcel(List<BookingModel> bookings, String filter) async {
    final excel = Excel.createExcel();
    final Sheet sheetObject = excel['Report'];
    excel.setDefaultSheet('Report');
    
    // Add Headers
    sheetObject.appendRow([
      TextCellValue('ID'),
      TextCellValue('Date'),
      TextCellValue('Customer'),
      TextCellValue('Service'),
      TextCellValue('Barber'),
      TextCellValue('Status'),
      TextCellValue('Amount (Rp)')
    ]);

    final DateFormat formatter = DateFormat('dd MMM yyyy, HH:mm');
    double totalRevenue = 0;

    for (var b in bookings) {
      final customerName = b.customerName ?? 'Walk-in';
      final serviceName = b.service?.name ?? '-';
      final barberName = b.barber?.name ?? '-';
      final dateStr = formatter.format(b.bookingDate.toLocal());
      final amount = b.totalPrice ?? 0.0;
      totalRevenue += amount;

      sheetObject.appendRow([
        TextCellValue(b.id.substring(0, 8)),
        TextCellValue(dateStr),
        TextCellValue(customerName),
        TextCellValue(serviceName),
        TextCellValue(barberName),
        TextCellValue(b.status),
        DoubleCellValue(amount),
      ]);
    }

    // Add empty row
    sheetObject.appendRow([TextCellValue('')]);
    
    // Add Summary
    sheetObject.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('Total Bookings:'),
      IntCellValue(bookings.length),
      TextCellValue('')
    ]);
    
    sheetObject.appendRow([
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue(''),
      TextCellValue('Total Revenue (Rp):'),
      DoubleCellValue(totalRevenue),
      TextCellValue('')
    ]);

    var fileBytes = excel.save();
    if (fileBytes != null) {
      await saveAndShareFile(fileBytes, 'Financial_Report_$filter.xlsx');
    }
  }
}
