import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../theme/app_color.dart';

class DetailProfileScreen extends StatelessWidget {
  const DetailProfileScreen({super.key, required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final role = _roleFor(profile);
    final memberNumber = profile.id.toString().padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: const Text('DETAIL ANGGOTA')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Text(
              'ANGGOTA / $memberNumber',
              style: const TextStyle(
                color: AppColor.primaryPurple,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColor.primaryContainer,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      profile.imageAsset,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name,
                        style: const TextStyle(
                          color: AppColor.textPrimary,
                          fontSize: 24,
                          height: 1.2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'NIM ${profile.nim}',
                        style: const TextStyle(
                          color: AppColor.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _RoleBadge(role: role),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Text(
              'TENTANG KELOMPOK',
              style: TextStyle(
                color: AppColor.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Kami merancang ruang belajar sederhana untuk menyimpan pengetahuan dan mengulangnya, satu kartu pada satu waktu.',
              style: TextStyle(
                color: AppColor.textSecondary,
                fontSize: 15,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 22),
            _InfoCard(
              icon: Icons.person_outline,
              title: 'TENTANG SAYA',
              description: profile.aboutme?.toString() ?? '',
            ),
            const SizedBox(height: 14),
            _InfoCard(
              icon: Icons.lightbulb_outline,
              title: 'KONTRIBUSI PROYEK',
              description:
                  'Berkolaborasi membangun Kartu Pintar sebagai $role, mendukung pengalaman belajar yang sederhana dan mudah digunakan.',
            ),
            const SizedBox(height: 22),
            const Text(
              'KARTU PINTAR',
              style: TextStyle(
                color: AppColor.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _roleFor(Profile profile) {
  final about = profile.aboutme?.toString() ?? '';
  const marker = 'sebagai ';
  final roleStart = about.toLowerCase().indexOf(marker);
  if (roleStart < 0) return 'Anggota kelompok';
  return about.substring(roleStart + marker.length).replaceAll('.', '').trim();
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColor.primaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        role,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColor.primaryPurple,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColor.surfaceWhite,
        border: Border.all(color: AppColor.borderSlate),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColor.primaryPurple),
              const SizedBox(width: 9),
              Text(
                title,
                style: const TextStyle(
                  color: AppColor.primaryPurple,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              color: AppColor.textSecondary,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
