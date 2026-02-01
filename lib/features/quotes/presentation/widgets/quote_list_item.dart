import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/quote_model.dart';

class QuoteListItem extends StatelessWidget {
  final QuoteModel quote;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const QuoteListItem({
    super.key,
    required this.quote,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPending = quote.status == 'borrador';
    final Color statusColor = isPending ? Colors.orange : const Color(0xFF00C6AD);
    final String statusText = isPending ? 'Borrador' : 'Creada';
    final IconData statusIcon = isPending ? Icons.edit_note_outlined : Icons.check_circle_outline;

    final String formattedDate = DateFormat('dd/MM/yy', 'es_CO').format(quote.creationDate.toLocal());
    final String formattedTime = DateFormat('hh:mm a', 'es_CO').format(quote.creationDate.toLocal());
    final String servicesSummary = quote.items.map((item) => item.serviceName).join(', ');

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(quote.clientName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              servicesSummary,
              style: const TextStyle(color: Colors.black54, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildDetailItem(Icons.access_time_outlined, formattedTime),
                const SizedBox(width: 16),
                _buildDetailItem(Icons.calendar_today_outlined, formattedDate),
                const Spacer(),
                _buildDetailItem(statusIcon, statusText, color: statusColor),
              ],
            ),
            const SizedBox(height: 20),
            isPending ? _buildPendingButtons(context) : _buildFinalizedButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text, {Color color = Colors.black54}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildFinalizedButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF27AE60),
              side: const BorderSide(color: Color(0xFF27AE60)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Editar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Ver detalles'),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Eliminar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('Editar'),
          ),
        ),
      ],
    );
  }
}