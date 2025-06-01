# CardSense AI Database Documentation

## 📋 Overview

This directory contains all database-related scripts and documentation for the CardSense AI application. The database is designed to work with Supabase PostgreSQL and follows best practices for security, performance, and scalability.

## 🗂️ File Structure

```
database/
├── README.md                     # This documentation
├── schema/
│   ├── 01_extensions.sql         # PostgreSQL extensions
│   ├── 02_core_tables.sql        # Core application tables
│   ├── 03_indexes.sql            # Performance indexes
│   ├── 04_triggers.sql           # Database triggers
│   ├── 05_functions.sql          # Stored procedures/functions
│   ├── 06_rls_policies.sql       # Row Level Security policies
│   └── 07_storage_setup.sql      # Supabase storage configuration
├── seeds/
│   ├── development_seed.sql      # Development/testing data
│   └── production_seed.sql       # Production reference data only
├── migrations/
│   └── (future migration files)
└── scripts/
    ├── setup_development.sql     # Complete development setup
    ├── setup_production.sql      # Production-safe setup
    └── cleanup.sql               # Database cleanup script
```

## 🚀 Quick Setup

### For Development Environment

```bash
# Run the complete development setup
psql -h your-supabase-host -U postgres -d postgres -f scripts/setup_development.sql
```

### For Production Environment

```bash
# Run production-safe setup (no test data)
psql -h your-supabase-host -U postgres -d postgres -f scripts/setup_production.sql
```

## 📊 Database Schema Overview

### Core Entities

1. **Users & Authentication**
   - `user_profiles` - Extended user information
   - Integrates with Supabase auth system

2. **Credit Card Management**
   - `card_issuers` - Bank/issuer information
   - `card_categories` - Card type classifications
   - `user_cards` - User's credit cards

3. **Financial Data**
   - `transactions` - All user transactions
   - `spending_categories` - Transaction categorization
   - `spending_summaries` - Monthly analytics

4. **AI & Communication**
   - `chat_conversations` - Chat session management
   - `chat_messages` - Individual messages

5. **Notifications & Alerts**
   - `notifications` - User notifications
   - `alert_rules` - Automated alert configuration

6. **Analytics**
   - `user_engagement` - User behavior tracking

### Security Features

- **Row Level Security (RLS)** on all user data tables
- **Data encryption** for sensitive information
- **Audit trails** with automatic timestamps
- **Input validation** through CHECK constraints

### Performance Features

- **Strategic indexes** for common query patterns
- **JSONB fields** for flexible data storage
- **Efficient data types** for optimal storage
- **Query optimization** for mobile app usage

## 🔒 Security Considerations

### Sensitive Data Handling

1. **Credit Card Information**
   - Only store last 4 digits of card numbers
   - Use encryption for any sensitive fields
   - Never store full card numbers or CVV

2. **Personal Information**
   - Phone numbers and personal details are optional
   - Profile data is protected by RLS
   - Audit trails for all data changes

3. **API Keys & Tokens**
   - No API keys stored in database
   - Use Supabase environment variables
   - Proper token rotation policies

### Row Level Security (RLS)

All user data tables have RLS policies ensuring:
- Users can only access their own data
- Proper authentication required
- Admin access controlled through service role

## 📈 Performance Optimization

### Indexing Strategy

- **User-based queries**: Indexes on `user_id` fields
- **Time-based queries**: Indexes on timestamp fields
- **Search functionality**: Composite indexes for common filters
- **Analytics queries**: Specialized indexes for reporting

### Query Patterns

- **Paginated results** for large datasets
- **Efficient joins** using foreign keys
- **Aggregation optimization** for analytics
- **Real-time subscriptions** for chat features

## 🔄 Data Flow

### User Onboarding
1. User registers through Supabase Auth
2. Profile created in `user_profiles`
3. Onboarding preferences stored
4. Initial cards added to `user_cards`

### Transaction Processing
1. Transactions inserted into `transactions`
2. Automatic categorization applied
3. Monthly summaries updated
4. Notifications triggered if needed

### AI Chat Integration
1. Conversations tracked in `chat_conversations`
2. Messages stored in `chat_messages`
3. Real-time updates through Supabase
4. Analytics captured for improvements

## 🧪 Testing

### Development Data

The development seed includes:
- Sample users with various profiles
- Test credit cards from major issuers
- Realistic transaction history
- Chat conversation examples

### Production Considerations

Production setup excludes:
- Test user accounts
- Sample transactions
- Development-specific configurations
- Debug data

## 📱 Mobile App Integration

### Offline Support

- **Local caching** strategies for critical data
- **Sync mechanisms** for offline changes
- **Conflict resolution** for concurrent updates

### Real-time Features

- **Live chat** updates through Supabase realtime
- **Instant notifications** for important events
- **Balance updates** as transactions occur

## 🔧 Maintenance

### Regular Tasks

1. **Index maintenance** for performance
2. **Data archiving** for old transactions
3. **Security audits** of RLS policies
4. **Performance monitoring** of slow queries

### Backup Strategy

- **Automated backups** through Supabase
- **Point-in-time recovery** capability
- **Cross-region replication** for disaster recovery

## 📞 Support

For database-related issues:

1. Check the logs in Supabase dashboard
2. Review RLS policies for access issues
3. Monitor performance metrics
4. Contact support with specific error messages

## 🔄 Version History

- **v1.0.0** - Initial schema design
- **v1.1.0** - Added analytics tables
- **v1.2.0** - Enhanced security policies
- **v1.3.0** - Performance optimizations

---

> **Note**: Always test schema changes in development environment before applying to production. 