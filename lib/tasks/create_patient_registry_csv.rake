require 'csv'

namespace :data do
  desc "Gives a report of participantes with the same MRN, likely to be duplicates people with incorrect data entry"
  task duplicate_mrn_report: :environment do
    CSV.open("tmp/duplicate_mrns.csv","wb") do |csv|
      Participant.all.to_a.group_by{ |p| [p.mrn.strip] }.each do |key, rows|
        if rows.size > 1
          puts "I finded one"
          rows.each do |row|
            csv << [
              row.mrn, row.first_name, row.middle_initial, row.last_name, row.protocols.map(&:id).join(",")
            ]
          end
        end
      end
    end
  end

  desc "Create patient registry file that can be used to merge duplicate participants"
  task create_patient_registry_csv: :environment do

    #Patient ID (Records to be Merged)  Patient MRN Patient Name  Patient Middle Initial  Patient Status  Patient DOB Patient Gender  Patient Ethnicity Patient Race  Patient Address Patient Phone Number  Patient City  Patient State Patient Zip Code  Patient External I
    attrs = [
      # id is 0
      :mrn, #1
      :last_name, #2
      :first_name, #3
      :middle_initial,
      :status,
      :date_of_birth,
      :gender,
      :ethnicity,
      :race,
      :address,
      :phone,
      :city,
      :state,
      :zipcode,
      :external_id
    ]

    CSV.open("tmp/patient_registry.csv","wb") do |csv|

      csv << [
        "Patient ID (Records to Merge)", "Patient MRN", "Patient Name",  "Patient Middle Initial",  "Patient Status",  "Patient DOB", "Patient Gender",  "Patient Ethnicity", "Patient Race",  "Patient Address", "Patient Phone Number",  "Patient City",  "Patient State", "Patient Zip Code",  "Patient External ID"
      ]
      Participant.all.to_a.group_by{ |p| [p.last_name.downcase.strip,p.first_name.downcase.strip,p.mrn.strip] }.each do |key, rows|

        new_row = []
        new_row[0] = []

        rows.sort_by{ |r| r.id}.each do |row|
          new_row[0] << row.id
          attrs.each_with_index do |attr, index|
            unless row == rows.last && rows.size > 1
              new_row[index+1] = row.send(attr) unless row.send(attr).blank?
            end
          end
        end

        new_row[0] = new_row[0].join(";")
        new_row[2] = "#{new_row[3]} #{new_row[2]}"
        new_row.delete_at(3)
        csv << new_row
      end
    end

  end
end

