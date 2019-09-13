echo "merge duplicate participants"
bin/rake data:merge_duplicate_participants

echo "fix one time fee line items"
bin/rake data:fix_one_time_fee_line_items
