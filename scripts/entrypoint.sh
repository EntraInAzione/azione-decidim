#!/bin/sh
# encoding: utf-8

RAILS_ENV=${RAILS_ENV:-"production"}
ADMIN_EMAIL=${ADMIN_EMAIL:-"decidim@azione.it"}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-"azione_decidim"}
ORG_ADMIN=${ORG_ADMIN:-"decidim@azione.it"}
ORG_NAME=${ORG_NAME:-"PartecipAzione"}
ORG_HOST=${ORG_HOST:-"localhost:3000"}
ORG_DESCRIPTION=${ORG_DESCRIPTION:-"PartecipAzione - piattaforma di democrazia partecipativa di Azione"}
ORG_ID=${ORG_ID:-1}
LOCALE=${LOCALE:-"it"}
SMTP_HOST=${SMTP_HOST:-"mailer"}
SMTP_PORT=${SMTP_PORT:-"25"}
SMTP_DOMAIN=${SMTP_DOMAIN:-""}
SMTP_USERNAME=${SMTP_USERNAME:-""}
SMTP_PASSWORD=${SMTP_PASSWORD:-""}


echo "---- Run cron ----"
RAILS_ENV=${RAILS_ENV} bundle exec whenever --update-crontab

RAILS_ENV=${RAILS_ENV} bin/rails decidim:upgrade

echo "---- Update config ----"
sed -i "s/config\.application_name = 'My Application Name'/config.application_name = '$ORG_NAME'/g" ./config/initializers/decidim.rb
sed -i "s/config\.mailer_sender = 'change-me\@domain\.org'/config.mailer_sender = '$ADMIN_EMAIL'/g" ./config/initializers/decidim.rb
sed -i "s/config\.available_locales \= \[\:en\, \:ca\, \:es\]/config\.available_locales \= \[\:en\, \:es\, \:it\]/g" ./config/initializers/decidim.rb
sed -i "s/config\.default_locale = \:en/config\.default_locale = \:it/g" ./config/initializers/decidim.rb
sed -i "s/# config\.force_ssl \= true/config\.force_ssl \= false/g" ./config/initializers/decidim.rb
sed -i "s/# config\.force_ssl \= true/config\.force_ssl \= false/g" ./config/environments/production.rb


echo "---- Connecting to DB ----"
echo "If db already exists, show errors, no worries !"
RAILS_ENV=${RAILS_ENV} bin/rails db:migrate
RAILS_ENV=${RAILS_ENV} bin/delayed_job start

echo "---- Create Admin ----"
(
    echo "Decidim::System::Admin.create(id: ${ORG_ID}, email: '${ADMIN_EMAIL}', password: '${ADMIN_PASSWORD}', password_confirmation: '${ADMIN_PASSWORD}')" ;
    # echo "Decidim::Organization.create(id: ${ORG_ID}, name: '${ORG_NAME}', host: '${ORG_HOST}', default_locale: '${LOCALE}', available_locales: ['en', 'it'], description: '${ORG_DESCRIPTION}', logo: 'EntrainAzione.png', twitter_handler: '@6inAzione', show_statistics: true, favicon: '6_in_Azione_LOGO.png', instagram_handler: 'azionemilano', facebook_handler: nil, youtube_handler: nil, github_handler: nil, official_img_header: nil, official_img_footer: nil, official_url: 'https://www.azione.it/', reference_prefix: 'azione', secondary_hosts: [], available_authorizations: [], header_snippets: nil, cta_button_text: {'${LOCALE}': 'Cosa posso fare?'}, cta_button_path: 'pages/help', enable_omnipresent_banner: true, omnipresent_banner_title: {'${LOCALE}': '${ORG_NAME}'}, omnipresent_banner_short_description: {'${LOCALE}': 'Un partito vicino alle esigenze dei suoi elettori deve utilizzare meccanismi di democrazia partecipativa'}, omnipresent_banner_url: '${ORG_HOST}/pages/participatory_processes', highlighted_content_banner_enabled: true, highlighted_content_banner_title: {'${LOCALE}': '\'Immuni\'​, crisi economica e democrazia partecipativa'}, highlighted_content_banner_short_description: {'${LOCALE}': '<p>Ogni settimana approfondimenti e commenti su un argomento politico o di attualità. Leggi e commenta.</p>'}, highlighted_content_banner_action_title: {'${LOCALE}': 'Vai al blog'}, highlighted_content_banner_action_subtitle: {'${LOCALE}': ''}, highlighted_content_banner_action_url: '${ORG_HOST}/processes/approsett/f/9/', highlighted_content_banner_image: 'CIO_Week_In_Review_Antenna1.png', tos_version: '2020-05-22 12:03:40.506047', badges_enabled: true, send_welcome_notification: true, welcome_notification_subject: {'${LOCALE}': 'Grazie per esserti iscritto a {{organization}}!'}, welcome_notification_body: {'${LOCALE}': '<p>Ciao {{name}}, grazie per esserti iscritto a {{organization}} e benvenuto!</p><ul><li>Se vuoi avere una rapida idea di cosa puoi fare qui, dai un occhiata alla sezione <a href=\"{{help_url}}\">Aiuto</a> .</li><li>Una volta letto, riceverai il tuo primo badge. Ecco un <a href=\"{{badges_url}}\">elenco di tutti i badge</a> è possibile ottenere, come si partecipa a {{organization}}</li><li>Da ultimo, ma non meno importante, uniscono altre persone, condividere con loro l esperienza di essere impegnati e partecipano a {{organization}}. Fare proposte, commentare, discutere, pensare a come contribuire al bene comune, fornire argomenti per convincere, ascoltare e leggere per essere convinti, esprimere le proprie idee in modo concreto e diretto, rispondere con pazienza e decisione, difendere le proprie idee e mantenere una mente aperta per collaborare e unire le idee degli altri.</li></ul>'}, users_registration_mode: 'enabled', id_documents_methods: ['online'], id_documents_explanation_text: {}, user_groups_enabled: true, smtp_settings: {'from'=>'${SMTP_DOMAIN}', 'domain'=>'${SMTP_DOMAIN}', 'port'=>'${SMTP_PORT}', 'address'=>'${SMTP_HOST}', 'user_name'=>'${SMTP_USERNAME}', 'from_email'=>'${ADMIN_EMAIL}', 'from_label'=>'', 'encrypted_password'=>'${SMTP_PASSWORD}'}, colors: {'alert': '#ec5840', 'primary': '#003399', 'success': '#57d685', 'warning': '#ffae00', 'secondary': '#FFCC00'}, force_users_to_authenticate_before_access_organization: true,  omniauth_settings: {'omniauth_settings_developer_icon'=>'', 'omniauth_settings_developer_enabled'=>false}, rich_text_editor_in_public_views: false, admin_terms_of_use_body: {'${LOCALE}': '<h2>TERMINI DI UTILIZZO DELL AMMINISTRATORE</h2><p>Ci auguriamo che tu abbia ricevuto la raccomandazione dall amministratore del sistema locale. Solitamente si riduce a queste quattro cose:</p><ol><li>Rispetta la privacy degli altri.</li><li>Pensa prima di cliccare.</li><li>Da grande potenzialità derivano grandi responsabilità.</li><li>La supercazzola lasciamola a Conte</li></ol>'}, time_zone: 'Rome')" ;
    
    # echo "Decidim::StaticPage.create('title': {'${LOCALE}': 'Titolo predefinito per terms-and-conditions'}, 'slug': 'terms-and-conditions', 'content': {'${LOCALE}': 'Si prega di aggiungere contenuto significativo alla pagina statica terms-and-conditions sul pannello di amministrazione.'}, 'decidim_organization_id': ${ORG_ID}, 'show_in_footer': true)" ;
    # echo "Decidim::StaticPage.create('title': {'${LOCALE}': 'Titolo predefinito per faq'}, 'slug': 'faq', 'content': 'Si prega di aggiungere contenuto significativo alla pagina statica faq sul pannello di amministrazione.', 'decidim_organization_id': ${ORG_ID}, 'show_in_footer': true)" ;
    # echo "Decidim::StaticPage.create('title': {'${LOCALE}': 'Titolo predefinito per accessibility'}, 'slug': 'accessibility', 'content': 'Si prega di aggiungere contenuto significativo alla pagina statica accessibility sul pannello di amministrazione', 'decidim_organization_id': ${ORG_ID}, 'show_in_footer': true)" ;
    # echo "Decidim::StaticPage.create('title': {'${LOCALE}': 'Cosa posso fare in testing?'}, 'slug': 'help', 'content': '\\u003cp\\u003eIn testing puoi partecipare e decidere su diversi argomenti, attraverso gli spazi che vedi nel menu in alto: Processi, Assemblee, Iniziative, Consultazioni.\\u003c/p\\u003e \\u003cp\\u003eAll interno di ognuna troverai diverse opzioni per partecipare: fare proposte - individualmente o con altre persone-, prendere parte ai dibattiti, dare la priorità ai progetti da attuare, partecipare alle riunioni faccia a faccia e altre azioni.\\u003c/p\\u003e', 'decidim_organization_id': ${ORG_ID}, 'weight': 0, 'topic_id': 1)" ;
    # echo "Decidim::StaticPage.create('title': {'${LOCALE}': 'Cos è un processo partecipativo?'}, 'slug': 'participatory_processes', 'content': '\\u003cp\\u003eA \\u003cstrong\\u003eprocesso partecipativo\\u003c/strong\\u003e è una sequenza di attività partecipative (ad esempio, prima compilando un sondaggio, poi formulando proposte, discutendole in riunioni faccia a faccia o virtuali e infine dando la priorità a esse) allo scopo di definire e prendere una decisione su un argomento specifico.\\u003c/p\\u003e \\u003cp\\u003eEsempi di processi partecipativi sono: un processo di elezione dei membri del comitato (in cui le candidature vengono presentate per la prima volta, poi discusse e infine si sceglie una candidatura), i budget partecipativi (dove le proposte sono fatte, valutate economicamente e votate con i soldi disponibili), un processo di pianificazione strategica, la stesura collaborativa di un regolamento o norma, la progettazione di uno spazio urbano o la produzione di un piano di politica pubblica.\\u003c/p\\u003e', 'decidim_organization_id': ${ORG_ID}, 'topic_id': 1)" ;
    # echo "Decidim::ContextualHelpSection.create('section_id': 'participatory_processes', 'organization_id': ${ORG_ID}, 'content': {'${LOCALE}': '\\u003cp\\u003eA \\u003cstrong\\u003eprocesso partecipativo\\u003c/strong\\u003e è una sequenza di attività partecipative (ad esempio, prima compilando un sondaggio, poi formulando proposte, discutendole in riunioni faccia a faccia o virtuali e infine dando la priorità a esse) allo scopo di definire e prendere una decisione su un argomento specifico.\\u003c/p\\u003e \\u003cp\\u003eEsempi di processi partecipativi sono: un processo di elezione dei membri del comitato (in cui le candidature vengono presentate per la prima volta, poi discusse e infine si sceglie una candidatura), i budget partecipativi (dove le proposte sono fatte, valutate economicamente e votate con i soldi disponibili), un processo di pianificazione strategica, la stesura collaborativa di un regolamento o norma, la progettazione di uno spazio urbano o la produzione di un piano di politica pubblica.\\u003c/p\\u003e'})" ;
    # echo "Decidim::StaticPage.create('title': 'Cosa sono le assemblee?', 'slug': 'assemblies', 'content': {'${LOCALE}': '\\u003cp\\u003eUn assemblaggio è un gruppo di membri di un organizzazione che si incontrano periodicamente per prendere decisioni su un area o un ambito specifico dell organizzazione.\\u003c/p\\u003e \\u003cp\\u003eassemblee tengono riunioni, alcune sono private e altre sono aperte. Se sono aperti, è possibile parteciparvi (ad esempio: partecipare se la capacità lo consente, aggiungendo punti all ordine del giorno, o commentando le proposte e le decisioni prese da questo organo).\\u003c/p\\u003e \\u003cp\\u003eEsempi: un assemblea generale (che si riunisce una volta all anno per definire le principali linee di azione dell organizzazione e gli organi esecutivi per voto), un consiglio consultivo per la parità (che si riunisce ogni due mesi per presentare proposte su come migliorare le relazioni di genere nell organizzazione), una commissione di valutazione (che si riunisce ogni mese per monitorare un processo) o un organismo di garanzia (che raccoglie incidenti, abusi o proposte per migliorare le procedure decisionali) sono tutti esempi di assemblee.\\u003c/p\\u003e'}, 'decidim_organization_id': '2', 'topic_id': 1)" ;
    # echo "Decidim::ContextualHelpSection.create('section_id': 'assemblies', 'organization_id': ${ORG_ID}, 'content': {'${LOCALE}': '\\u003cp\\u003eUn assemblaggio è un gruppo di membri di un organizzazione che si incontrano periodicamente per prendere decisioni su un area o un ambito specifico dell organizzazione.\\u003c/p\\u003e \\u003cp\\u003eassemblee tengono riunioni, alcune sono private e altre sono aperte. Se sono aperti, è possibile parteciparvi (ad esempio: partecipare se la capacità lo consente, aggiungendo punti all ordine del giorno, o commentando le proposte e le decisioni prese da questo organo).\\u003c/p\\u003e \\u003cp\\u003eEsempi: un assemblea generale (che si riunisce una volta all anno per definire le principali linee di azione dell organizzazione e gli organi esecutivi per voto), un consiglio consultivo per la parità (che si riunisce ogni due mesi per presentare proposte su come migliorare le relazioni di genere nell organizzazione), una commissione di valutazione (che si riunisce ogni mese per monitorare un processo) o un organismo di garanzia (che raccoglie incidenti, abusi o proposte per migliorare le procedure decisionali) sono tutti esempi di assemblee.\\u003c/p\\u003e'})" ;
    
    # echo "Decidim::ContentBlock.create('decidim_organization_id': ${ORG_ID}, 'manifest_name': 'hero', 'scope_name': 'homepage', 'published_at': '2020-10-24 11:06:31.780379', 'weight': 10)" ;
    # echo "Decidim::ContentBlock.create('decidim_organization_id': ${ORG_ID}, 'manifest_name': 'hero', 'scope_name': 'homepage', 'published_at': '2020-10-24 11:06:31.780379', 'weight': 20)" ;
    # echo "Decidim::ContentBlock.create('decidim_organization_id': ${ORG_ID}, 'manifest_name': 'hero', 'scope_name': 'homepage', 'published_at': '2020-10-24 11:06:31.780379', 'weight': 30)" ;
    # echo "Decidim::ContentBlock.create('decidim_organization_id': ${ORG_ID}, 'manifest_name': 'hero', 'scope_name': 'homepage', 'published_at': '2020-10-24 11:06:31.780379', 'weight': 40)" ;
    # echo "Decidim::ContentBlock.create('decidim_organization_id': ${ORG_ID}, 'manifest_name': 'hero', 'scope_name': 'homepage', 'published_at': '2020-10-24 11:06:31.780379', 'weight': 50)" ;
    # echo "Decidim::ContentBlock.create('decidim_organization_id': ${ORG_ID}, 'manifest_name': 'hero', 'scope_name': 'homepage', 'published_at': '2020-10-24 11:06:31.780379', 'weight': 60)" ;
    # echo "Decidim::ContentBlock.create('decidim_organization_id': ${ORG_ID}, 'manifest_name': 'hero', 'scope_name': 'homepage', 'published_at': '2020-10-24 11:06:31.780379', 'weight': 70)" ;
    # echo "Decidim::ContentBlock.create('decidim_organization_id': ${ORG_ID}, 'manifest_name': 'hero', 'scope_name': 'homepage', 'published_at': '2020-10-24 11:06:31.780379', 'weight': 80)" ;
    
    # echo "Decidim::User.create(id: ${ORG_ID}, 'email': '${ORG_ADMIN}', 'password': '${ADMIN_PASSWORD}', password_confirmation: '${ADMIN_PASSWORD}', 'decidim_organization_id': ${ORG_ID}, 'name': '${ORG_NAME}', 'admin': true, 'nickname': '${ORG_NAME}', 'type': 'Decidim::User')" ;
    # echo "Decidim::SearchableResource.create('content_a': '${ORG_NAME}', 'content_b': '', 'content_c': '', 'content_d': '', 'locale': '${LOCALE}', 'datetime': '2020-10-24 11:06:32.052804', 'decidim_organization_id': ${ORG_ID}, 'resource_type': 'Decidim::User', 'resource_id': 1)"
) | bin/rails console -e ${RAILS_ENV}

echo "---- Launch Server ----"
RAILS_ENV=${RAILS_ENV} bin/rails s -b 0.0.0.0


# DEBUG -- : [9fe3a02b-bef4-4f05-ae8b-38d6402259ac]   Decidim::User Create (0.8ms)  INSERT INTO "decidim_users" ("email", "encrypted_password", "created_at", "updated_at", "decidim_organization_id", "confirmation_token", "confirmation_sent_at", "name", "locale", "email_on_notification", "nickname", "accepted_tos_version", "type") VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) RETURNING "id"  [["email", "patrickjusic96@gmail.com"], ["encrypted_password", "$2a$11$G8xgTsDyVt7C4PdJyzmHAeFGIqZetf2F43x4z9aE8UYlSIRO47gD2"], ["created_at", "2020-10-30 22:40:47.755430"], ["updated_at", "2020-10-30 22:40:47.755430"], ["decidim_organization_id", 1], ["confirmation_token", "sCwVis3QXQuYGSrgJ-52"], ["confirmation_sent_at", "2020-10-30 22:40:47.755535"], ["name", "Patrick"], ["locale", "it"], ["email_on_notification", true], ["nickname", "xn3cr0nx"], ["accepted_tos_version", "2020-10-30 22:20:43.117508"], ["type", "Decidim::User"]]
# ActionMailer::Base.smtp_settings = {:address=> "in-v3.mailjet.com",:port=> 25,:domain=> nil,:user_name=> "657288d8a677f13ab927ac92562fb967",:password=> "2f8bfff90441f4123af9eed6c3587f33",:authentication=> "plain",:enable_starttls_auto => true}
# Decidim::User.create(id: 2, 'email': 'patrick-96@live.it', 'password': 'Necrozfear1', password_confirmation: 'Necrozfear1', 'decidim_organization_id': 1, 'name': 'FACTOTUM', 'admin': true, 'nickname': 'FACT', 'type': 'Decidim::User')