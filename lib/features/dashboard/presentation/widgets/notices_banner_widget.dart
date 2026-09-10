import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/localization/l10n_ext.dart';
import '../../domain/entities/notice_snippet_entity.dart';

class NoticesBannerWidget extends StatelessWidget {
  final List<NoticeSnippetEntity> notices;
  final ValueChanged<NoticeSnippetEntity>? onNoticeTap;

  const NoticesBannerWidget({
    super.key,
    required this.notices,
    this.onNoticeTap,
  });

  @override
  Widget build(BuildContext context) {
    if (notices.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.campaign,
              color: theme.colorScheme.primary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              context.l10n.buildingNotices,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        ...notices.map((notice) => _NoticeItem(
              notice: notice,
              onTap: onNoticeTap != null ? () => onNoticeTap!(notice) : null,
            )),
      ],
    );
  }
}

class _NoticeItem extends StatelessWidget {
  final NoticeSnippetEntity notice;
  final VoidCallback? onTap;

  const _NoticeItem({
    required this.notice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notice.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (notice.content != null &&
                      notice.content!.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      notice.content!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  SizedBox(height: 4.h),
                  Text(
                    notice.publishedAt,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
