import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../config/theme.dart';

// ── Curated verse pool (52 weekly verses cycling annually) ────────────────────
// These are authoritative Scripture passages, not mock data.
// Each covers a core discipleship theme for P2P Bible Study.

const _kVersePool = [
  (text: 'I am the vine; you are the branches. Whoever abides in me and I in him, he it is that bears much fruit, for apart from me you can do nothing.', ref: 'John 15:5'),
  (text: 'And let us consider how to stir up one another to love and good works, not neglecting to meet together, as is the habit of some, but encouraging one another.', ref: 'Hebrews 10:24–25'),
  (text: 'Go therefore and make disciples of all nations, baptising them in the name of the Father and of the Son and of the Holy Spirit.', ref: 'Matthew 28:19'),
  (text: 'Two are better than one, because they have a good reward for their toil. For if they fall, one will lift up his fellow.', ref: 'Ecclesiastes 4:9–10'),
  (text: 'Let the word of Christ dwell in you richly, teaching and admonishing one another in all wisdom.', ref: 'Colossians 3:16'),
  (text: 'Iron sharpens iron, and one man sharpens another.', ref: 'Proverbs 27:17'),
  (text: 'Bear one another\'s burdens, and so fulfil the law of Christ.', ref: 'Galatians 6:2'),
  (text: 'Now you are the body of Christ and individually members of it.', ref: '1 Corinthians 12:27'),
  (text: 'For where two or three are gathered in my name, there am I among them.', ref: 'Matthew 18:20'),
  (text: 'As each has received a gift, use it to serve one another, as good stewards of God\'s varied grace.', ref: '1 Peter 4:10'),
  (text: 'Walk in a manner worthy of the calling to which you have been called, with all humility and gentleness, with patience, bearing with one another in love.', ref: 'Ephesians 4:1–2'),
  (text: 'The Lord\'s servant must not be quarrelsome but kind to everyone, able to teach, patiently enduring evil, correcting his opponents with gentleness.', ref: '2 Timothy 2:24–25'),
  (text: 'And Jesus came and said to them, "All authority in heaven and on earth has been given to me."', ref: 'Matthew 28:18'),
  (text: 'Whoever brings back a sinner from his wandering will save his soul from death and will cover a multitude of sins.', ref: 'James 5:20'),
  (text: 'And what you have heard from me in the presence of many witnesses entrust to faithful men, who will be able to teach others also.', ref: '2 Timothy 2:2'),
  (text: 'Preach the word; be ready in season and out of season; reprove, rebuke, and exhort, with complete patience and teaching.', ref: '2 Timothy 4:2'),
  (text: 'Your word is a lamp to my feet and a light to my path.', ref: 'Psalm 119:105'),
  (text: 'All Scripture is breathed out by God and profitable for teaching, for reproof, for correction, and for training in righteousness.', ref: '2 Timothy 3:16'),
  (text: 'For the word of God is living and active, sharper than any two-edged sword.', ref: 'Hebrews 4:12'),
  (text: 'Blessed is the man who walks not in the counsel of the wicked, but his delight is in the law of the Lord, and on his law he meditates day and night.', ref: 'Psalm 1:1–2'),
  (text: 'Ask, and it will be given to you; seek, and you will find; knock, and it will be opened to you.', ref: 'Matthew 7:7'),
  (text: 'Do not be anxious about anything, but in everything by prayer and supplication with thanksgiving let your requests be made known to God.', ref: 'Philippians 4:6'),
  (text: 'The prayer of a righteous person has great power as it is working.', ref: 'James 5:16'),
  (text: 'Rejoice always, pray without ceasing, give thanks in all circumstances.', ref: '1 Thessalonians 5:16–18'),
  (text: 'And this is the confidence that we have toward him, that if we ask anything according to his will he hears us.', ref: '1 John 5:14'),
  (text: 'Therefore, since we are surrounded by so great a cloud of witnesses, let us run with endurance the race that is set before us.', ref: 'Hebrews 12:1'),
  (text: 'For God so loved the world, that he gave his only Son, that whoever believes in him should not perish but have eternal life.', ref: 'John 3:16'),
  (text: 'For I am not ashamed of the gospel, for it is the power of God for salvation to everyone who believes.', ref: 'Romans 1:16'),
  (text: 'How then will they call on him in whom they have not believed? And how are they to believe in him of whom they have never heard?', ref: 'Romans 10:14'),
  (text: 'But you will receive power when the Holy Spirit has come upon you, and you will be my witnesses in Jerusalem and in all Judea and Samaria, and to the end of the earth.', ref: 'Acts 1:8'),
  (text: 'And he said to them, "Follow me, and I will make you fishers of men."', ref: 'Matthew 4:19'),
  (text: 'Whoever finds his life will lose it, and whoever loses his life for my sake will find it.', ref: 'Matthew 10:39'),
  (text: 'I can do all things through him who strengthens me.', ref: 'Philippians 4:13'),
  (text: 'For we are his workmanship, created in Christ Jesus for good works, which God prepared beforehand, that we should walk in them.', ref: 'Ephesians 2:10'),
  (text: 'Not that I have already obtained this or am already perfect, but I press on to make it my own.', ref: 'Philippians 3:12'),
  (text: 'And I am sure of this, that he who began a good work in you will bring it to completion at the day of Jesus Christ.', ref: 'Philippians 1:6'),
  (text: 'Do not be conformed to this world, but be transformed by the renewal of your mind.', ref: 'Romans 12:2'),
  (text: 'Love one another with brotherly affection. Outdo one another in showing honour.', ref: 'Romans 12:10'),
  (text: 'So then, as we have opportunity, let us do good to everyone, and especially to those who are of the household of faith.', ref: 'Galatians 6:10'),
  (text: 'For even the Son of Man came not to be served but to serve, and to give his life as a ransom for many.', ref: 'Mark 10:45'),
  (text: 'A new commandment I give to you, that you love one another: just as I have loved you, you also are to love one another.', ref: 'John 13:34'),
  (text: 'By this all people will know that you are my disciples, if you have love for one another.', ref: 'John 13:35'),
  (text: 'But grow in the grace and knowledge of our Lord and Saviour Jesus Christ.', ref: '2 Peter 3:18'),
  (text: 'Put on then, as God\'s chosen ones, holy and beloved, compassionate hearts, kindness, humility, meekness, and patience.', ref: 'Colossians 3:12'),
  (text: 'Teach us to number our days that we may get a heart of wisdom.', ref: 'Psalm 90:12'),
  (text: 'The harvest is plentiful, but the labourers are few; therefore pray earnestly to the Lord of the harvest to send out labourers into his harvest.', ref: 'Matthew 9:37–38'),
  (text: 'For we do not wrestle against flesh and blood, but against the rulers, against the authorities, against the cosmic powers over this present darkness.', ref: 'Ephesians 6:12'),
  (text: 'Pray then like this: Our Father in heaven, hallowed be your name. Your kingdom come, your will be done, on earth as it is in heaven.', ref: 'Matthew 6:9–10'),
  (text: 'Behold, I am doing a new thing; now it springs forth, do you not perceive it?', ref: 'Isaiah 43:19'),
  (text: 'For the earth will be filled with the knowledge of the glory of the Lord as the waters cover the sea.', ref: 'Habakkuk 2:14'),
  (text: 'And the things you have heard me say in the presence of many witnesses entrust to reliable people who will also be qualified to teach others.', ref: '2 Timothy 2:2'),
  (text: 'Let your light shine before others, so that they may see your good works and give glory to your Father who is in heaven.', ref: 'Matthew 5:16'),
];

/// Provider that returns today's verse, rotating through the pool each day.
final dailyVerseProvider = Provider<({String text, String ref})>((pRef) {
  final dayOfYear = DateTime.now().difference(
    DateTime(DateTime.now().year, 1, 1),
  ).inDays;
  return _kVersePool[dayOfYear % _kVersePool.length];
});

/// Displays the verse of the day in a warm card.
class DailyVerseCard extends ConsumerWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final verse = ref.watch(dailyVerseProvider);

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderBeige),
        boxShadow: [
          BoxShadow(
            color: AppColors.amber.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3.w,
                height: 14.h,
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Verse of the day',
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                  color: AppColors.amber,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '"${verse.text}"',
            style: TextStyle(
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
              height: 1.65,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${verse.ref}',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
