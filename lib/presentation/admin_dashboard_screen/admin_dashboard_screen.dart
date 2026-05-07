import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/app_export.dart';
import '../../core/models/admin_insight_model.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  static Widget builder(BuildContext context) {
    return const AdminDashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    final insights = AdminInsight.mock;

    return Scaffold(
      backgroundColor: Color(0xFFF9F7F2), // Pale Sand
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            SizedBox(height: 32),
            _buildMainMetrics(insights),
            SizedBox(height: 32),
            _buildVibeSoulRadar(insights),
            SizedBox(height: 32),
            _buildDiscoveryVelocity(insights),
            SizedBox(height: 32),
            _buildNeighborhoodInsights(),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Color(0xFF1B3022)),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none_outlined, color: Color(0xFF1B3022)),
          onPressed: () {},
        ),
        SizedBox(width: 8),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Urban Intelligence',
          style: TextStyleHelper.instance.headline30ExtraBoldOutfit.copyWith(
            color: Color(0xFF1B3022),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Monitoring the pulse of LikeALocal ecosystem.',
          style: TextStyleHelper.instance.body14MediumInter.copyWith(
            color: Color(0xFF4D6353),
          ),
        ),
      ],
    );
  }

  Widget _buildMainMetrics(AdminInsight insights) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Authenticity',
                '${(insights.authenticityScore * 100).toInt()}%',
                Icons.verified_user_outlined,
                Color(0xFF3E5641),
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildMetricCard(
                'Conversion',
                '${insights.conversionRate}%',
                Icons.moving_outlined,
                Color(0xFFBDB76B),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildModerationEntryCard(insights.pendingModerationCount),
        SizedBox(height: 16),
        _buildActionRow(),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSmallActionCard(
            'Reports',
            '4 Active',
            Icons.report_problem_outlined,
            Color(0xFF8B0000),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildSmallActionCard(
            'Broadcast',
            'Send Alert',
            Icons.campaign_outlined,
            Color(0xFF3E5641),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallActionCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Color(0x33C1C9C1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModerationEntryCard(int count) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.adminModerationQueue),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Color(0xFF1B3022),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.gavel_outlined, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Moderation Queue',
                      style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Colors.white),
                    ),
                    Text(
                      '$count items pending review',
                      style: TextStyleHelper.instance.label10MediumInter.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 12),
          Text(
            value,
            style: TextStyleHelper.instance.display36ExtraBoldOutfit.copyWith(
              fontSize: 28,
              color: Color(0xFF191C1A),
            ),
          ),
          Text(
            title,
            style: TextStyleHelper.instance.label10MediumInter.copyWith(
              color: Color(0xFF4D6353),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVibeSoulRadar(AdminInsight insights) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Color(0xFF1B3022),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF1B3022).withOpacity(0.3),
                blurRadius: 20,
                offset: Offset(0, 10),
              )
            ],
          ),
          child: Stack(
            children: [
              _buildRadarPulse(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vibe Soul Correlation',
                    style: TextStyleHelper.instance.title18SemiBoldInter.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Aggregated user preference clusters.',
                    style: TextStyleHelper.instance.label10MediumInter.copyWith(
                      color: Colors.white.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 32),
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: RadarChart(
                      RadarChartData(
                        dataSets: [
                          RadarDataSet(
                            fillColor: Color(0xFFFFD700).withOpacity(0.4 * value),
                            borderColor: Color(0xFFFFD700).withOpacity(value),
                            entryRadius: 3 * value,
                            dataEntries: [
                              RadarEntry(value: insights.vibeSoulGastronomy * value),
                              RadarEntry(value: insights.vibeSoulArt * value),
                              RadarEntry(value: insights.vibeSoulHistory * value),
                              RadarEntry(value: insights.vibeSoulNightlife * value),
                              RadarEntry(value: insights.vibeSoulNature * value),
                            ],
                          ),
                        ],
                        radarShape: RadarShape.circle,
                        radarBorderData: BorderSide(color: Colors.white24),
                        tickBorderData: BorderSide(color: Colors.white10),
                        gridBorderData: BorderSide(color: Colors.white10),
                        getTitle: (index, angle) {
                          switch (index) {
                            case 0: return RadarChartTitle(text: 'Food');
                            case 1: return RadarChartTitle(text: 'Art');
                            case 2: return RadarChartTitle(text: 'History');
                            case 3: return RadarChartTitle(text: 'Night');
                            case 4: return RadarChartTitle(text: 'Nature');
                            default: return RadarChartTitle(text: '');
                          }
                        },
                        ticksTextStyle: TextStyle(color: Colors.transparent),
                        titleTextStyle: TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRadarPulse() {
    return Positioned.fill(
      child: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(seconds: 4),
          builder: (context, value, child) {
            return Container(
              width: 300 * value,
              height: 300 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(1 - value), width: 1),
              ),
            );
          },
          onEnd: () {},
        ),
      ),
    );
  }

  Widget _buildDiscoveryVelocity(AdminInsight insights) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeInOutQuad,
      builder: (context, value, child) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Color(0x33C1C9C1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 15,
                offset: Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Discovery Velocity',
                    style: TextStyleHelper.instance.title18SemiBoldInter,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F2E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+24%',
                      style: TextStyle(color: Color(0xFF3E5641), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Text(
                'New submissions over the last 7 days.',
                style: TextStyleHelper.instance.label10MediumInter.copyWith(color: Color(0xFF4D6353)),
              ),
              SizedBox(height: 32),
              AspectRatio(
                aspectRatio: 2,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: insights.discoveryVelocity.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value * value);
                        }).toList(),
                        isCurved: true,
                        color: Color(0xFF1B3022),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Color(0xFF1B3022).withOpacity(0.1 * value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNeighborhoodInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Neighborhood Hotspots',
          style: TextStyleHelper.instance.title18SemiBoldInter,
        ),
        SizedBox(height: 16),
        _buildNeighborhoodItem('Zamalek', 0.92, 'Trending: Chill'),
        _buildNeighborhoodItem('Maadi', 0.85, 'Trending: Food'),
        _buildNeighborhoodItem('Downtown', 0.78, 'Trending: History'),
      ],
    );
  }

  Widget _buildNeighborhoodItem(String name, double score, String trend) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            value: score,
            backgroundColor: Color(0xFFF0F4EC),
            color: Color(0xFF3E5641),
            strokeWidth: 4,
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyleHelper.instance.body14BoldInter),
                Text(trend, style: TextStyleHelper.instance.label10MediumInter.copyWith(color: Color(0xFF4D6353))),
              ],
            ),
          ),
          Text(
            '${(score * 100).toInt()}%',
            style: TextStyleHelper.instance.body14BoldInter.copyWith(color: Color(0xFF3E5641)),
          ),
        ],
      ),
    );
  }
}
