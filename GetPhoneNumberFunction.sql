create or replace FUNCTION       get_phone_number (
   pi_cust_acct_site_id   IN NUMBER,
   pi_phone_type          IN VARCHAR2
)
   RETURN VARCHAR2
IS
   po_phone_number   VARCHAR2 (50);
   v_cust_account_id number;
BEGIN
   po_phone_number := NULL;

-- retrieve phone from site level contact phone number
   BEGIN
      SELECT   *
        INTO   po_phone_number
        FROM   (  SELECT   hcp1.phone_area_code || hcp1.phone_number
                    FROM   hz_contact_points hcp1,
                           hz_cust_account_roles hcar,
                           ar_lookups look
                   WHERE       hcar.cust_acct_site_id = pi_cust_acct_site_id
                           AND hcp1.owner_table_id = hcar.party_id
                           AND hcp1.owner_table_name = 'HZ_PARTIES'
                           AND hcp1.phone_line_type = pi_phone_type
                           AND hcp1.status = 'A'
                           AND NVL (hcp1.contact_point_type, 'PHONE') NOT IN
                                    ('EDI', 'EMAIL', 'WEB')
                           AND NVL (hcp1.phone_line_type,
                                    hcp1.contact_point_type) = look.lookup_code
                           AND ( (look.lookup_type = 'COMMUNICATION_TYPE'
                                  AND look.lookup_code IN ('PHONE', 'TLX'))
                                OR (look.lookup_type = 'PHONE_LINE_TYPE'))
                --             ROWNUM <= 1
                ORDER BY   hcp1.primary_flag DESC)
       WHERE   ROWNUM <= 1;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         po_phone_number := NULL;
      WHEN TOO_MANY_ROWS
      THEN
         po_phone_number := NULL;
      WHEN OTHERS
      THEN
         po_phone_number := NULL;
   END;

if po_phone_number is null then 
-- retrieve site level phone number
   BEGIN
      SELECT   *
        INTO   po_phone_number
        FROM   (  
             SELECT   hcp1.phone_area_code || hcp1.phone_number
               FROM hz_contact_points hcp1,
                    hz_party_sites ps,
                    ar_lookups look,
                    hz_cust_acct_sites_all cs
              WHERE cs.cust_acct_site_id = pi_cust_acct_site_id
                and cs.party_site_id = ps.party_site_id
                AND hcp1.owner_table_id = ps.party_site_id
                AND hcp1.owner_table_name = 'HZ_PARTY_SITES'
                AND hcp1.phone_line_type = pi_phone_type
                AND hcp1.status = 'A'
                AND NVL (hcp1.contact_point_type, 'PHONE') NOT IN
                                                      ('EDI', 'EMAIL', 'WEB')
                AND NVL (hcp1.phone_line_type, hcp1.contact_point_type) =
                                                              look.lookup_code
                AND (   (    look.lookup_type = 'COMMUNICATION_TYPE'
                         AND look.lookup_code IN ('PHONE', 'TLX')
                        )
                     OR (look.lookup_type = 'PHONE_LINE_TYPE')
                    )
                ORDER BY   hcp1.primary_flag DESC)
       WHERE   ROWNUM <= 1;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         po_phone_number := NULL;
      WHEN TOO_MANY_ROWS
      THEN
         po_phone_number := NULL;
      WHEN OTHERS
      THEN
         po_phone_number := NULL;
   END;
end if;

if po_phone_number is null then 
-- retrieve account level contact phone number
begin
select cust_account_id into v_cust_account_id
from     hz_cust_acct_sites_all
where CUST_ACCT_SITE_ID = pi_cust_acct_site_id;

   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         v_cust_account_id := NULL;
      WHEN TOO_MANY_ROWS
      THEN
         v_cust_account_id := NULL;
      WHEN OTHERS
      THEN
         v_cust_account_id := NULL;
   END;
   BEGIN
      SELECT   *
        INTO   po_phone_number
        FROM   (  
        SELECT   hcp1.phone_area_code || hcp1.phone_number
                    FROM   hz_contact_points hcp1,
                           hz_cust_account_roles hcar,
                           ar_lookups look
                   WHERE       hcar.cust_acct_site_id is null
                           and hcar.cust_account_id = v_cust_account_id
                           AND hcp1.owner_table_id = hcar.party_id
                           AND hcp1.owner_table_name = 'HZ_PARTIES'
                           AND hcp1.phone_line_type = pi_phone_type
                           AND hcp1.status = 'A'
                           AND NVL (hcp1.contact_point_type, 'PHONE') NOT IN
                                    ('EDI', 'EMAIL', 'WEB')
                           AND NVL (hcp1.phone_line_type,
                                    hcp1.contact_point_type) = look.lookup_code
                           AND ( (look.lookup_type = 'COMMUNICATION_TYPE'
                                  AND look.lookup_code IN ('PHONE', 'TLX'))
                                OR (look.lookup_type = 'PHONE_LINE_TYPE'))
                ORDER BY   hcp1.primary_flag DESC)
       WHERE   ROWNUM <= 1;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         po_phone_number := NULL;
      WHEN TOO_MANY_ROWS
      THEN
         po_phone_number := NULL;
      WHEN OTHERS
      THEN
         po_phone_number := NULL;
   END;
end if;


   RETURN po_phone_number;
EXCEPTION
   WHEN NO_DATA_FOUND
   THEN
      RETURN NULL;
   WHEN OTHERS
   THEN
      RETURN NULL;
END get_phone_number; 