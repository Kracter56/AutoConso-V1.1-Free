//
//  textStrings.swift
//  AutoConso
//
//  Created by Edgar PETRUS on 31/08/2019.
//  Copyright © 2019 Edgar PETRUS. All rights reserved.
//

import Foundation


class textStrings {
	
	/* Generic texts */
	static var strOK = NSLocalizedString("OK", comment: "strOK")
	static var strJaiCompris = NSLocalizedString("J'ai compris.", comment: "strJaiCompris")
	static var strOui = NSLocalizedString("Oui", comment: "strOui")
	static var strNon = NSLocalizedString("Non", comment: "strNon")
	static var strJaccepte = NSLocalizedString("J'accepte", comment: "strJaccepte")
	static var strJeRefuse = NSLocalizedString("Je refuse", comment: "strJeRefuse")
	static var strErreur = NSLocalizedString("Erreur", comment: "strErreur")
	static var strRechercheEnCours = NSLocalizedString("Recherche en cours...", comment: "strRechercheEnCours")
	static var strFermer = NSLocalizedString("Fermer", comment: "strFermer")
	static var strEnregistrer = NSLocalizedString("Enregistrer", comment: "strEnregistrer")
	static var strChargement = NSLocalizedString("Chargement...", comment: "strChargement")
	static var strAnnuler = NSLocalizedString("Annuler", comment: "strAnnuler")
	static var strRelancer = NSLocalizedString("Relancer", comment: "strRelancer")
	static var strContinuer = NSLocalizedString("Continuer", comment: "strContinuer")
	static var strAdresse = NSLocalizedString("Adresse", comment: "strAdresse")
	static var strVille = NSLocalizedString("Ville", comment: "strVille")
	static var strRavitaillementCarburant = NSLocalizedString("Ravitaillement en carburant", comment: "strRavitaillementCarburant")
	static var strAlreadyOnStation = NSLocalizedString("Je suis dans une station", comment: "strAlreadyOnStation")
	static var detailsTicket = NSLocalizedString("Details du ticket", comment: "detailsTicket")
	static var strKilometrage = NSLocalizedString("Kilometrage", comment: "strKilometrage")
	static var strKMParcourus = NSLocalizedString("KM parcourus", comment: "strKMParcourus")
	static var nbLitres = NSLocalizedString("Nb de litres", comment: "nbLitres")
	static var typeParcours = NSLocalizedString("Type de parcours", comment: "typeParcours")
	static var strPrix = NSLocalizedString("Prix", comment: "strPrix")
	static var strMesNotes = NSLocalizedString("Mes Notes", comment: "strMesNotes")
	static var strCommentaire = NSLocalizedString("Commentaire", comment: "strCommentaire")
	static var strCodePostal = NSLocalizedString("Code Postal", comment: "strCodePostal")
	static var strConso = NSLocalizedString("Consommation (L/100km)", comment: "strConso")
	static var coutLitre = NSLocalizedString("Prix au Litre (€/L)", comment: "coutLitre")
	
	static var strStationName = NSLocalizedString("Nom de la station", comment: "strStationName")
	
	static var strSearch = NSLocalizedString("Rechercher", comment: "strSearch")
	
	static var strSelect = NSLocalizedString("Choisir", comment: "strSelect")
	static var strType = NSLocalizedString("Saisir", comment: "strType")
	
	static var photoStation = NSLocalizedString("Photo de la station", comment: "photoStation")
	static var createTicket = NSLocalizedString("Création d'un ticket", comment: "createTicket")
	
	static var strPlein = NSLocalizedString("Plein de carburant", comment: "strPlein")
	
	/* Types de parcours */
	static var typeCycle = NSLocalizedString("Type de cycle", comment: "typeCycle")
	static var cycleUrbain = NSLocalizedString("Urbain", comment: "cycleUrbain")
	static var cycleMixte = NSLocalizedString("Mixte", comment: "cycleMixte")
	static var cycleRoutier = NSLocalizedString("Routier", comment: "cycleRoutier")
	
	/* Popups */
	static var titleAdresseInexistante = NSLocalizedString("Adresse inexistante", comment: "titleAdresseInexistante")
	static var  messageAdresseInexistante = NSLocalizedString("Cette adresse n'existe pas.", comment: "messageAdresseInexistante")
	static var  kmerror = NSLocalizedString("Votre nouveau kilométrage doit être supérieur au dernier kilométrage relevé!", comment: "kmerror")
	
	static var titleNetworkNOK = NSLocalizedString("Connexion internet interrompue", comment: "titleNetworkNOK")
	static var messageNetworkNOK = NSLocalizedString("L'application n'est pas connectée à Internet. Une connexion internet stable est nécessaire pour que l'application fonctionne dans de meilleures conditions. La fonctionnalité de localisation véhicule ne sera pas utilisable dans cette session.", comment: "messageNetworkNOK")
	
	static var strVoirJustif = NSLocalizedString("Afficher l'image", comment: "strVoirJustif")
	
	static var titleNoStationSelected = NSLocalizedString("Aucune station sélectionnée", comment: "titleNoStationSelected")
	static var messageNoStationSelected = NSLocalizedString("Vous n'avez pas sélectionné de station. Relancez votre recherche.", comment: "messageNoStationSelected")
	
	/* This popup is displayed if GPS is not activated */
	static var titleEnableGPS = NSLocalizedString("Autorisation GPS", comment: "titleEnableGPS")
	static var messageEnableGPS = NSLocalizedString("L'app AutoConso a besoin d'accéder à votre localisation. Activer les permissions de localisation dans le menu Réglages de votre iPhone", comment: "messageEnableGPS")
	static var settingsButton = NSLocalizedString("Réglages", comment: "settingsButton")
	
	/* This popup is displayed if no station found around the user */
	static var titleAucuneStation = NSLocalizedString("Recherche invalide", comment: "titleAucuneStation")
	static var messageAucuneStation = NSLocalizedString("Votre recherche n'a donné aucun résultat. Voulez-vous ajouter une station ?", comment: "messageAucuneStation")
	
	static var strChercherStation = NSLocalizedString("Chercher une station", comment: "strChercherStation")
	static var strCritereRecherche = NSLocalizedString("Critères de recherche", comment: "strCritereRecherche")
	
	static var strGeolocationError = NSLocalizedString("Erreur de géolocalisation", comment: "strGeolocationError")
	static var strCheckGPSAuth = NSLocalizedString("Vérifiez vos autorisations GPS et rééssayez.", comment: "strCheckGPSAuth")
	
	/* Station header result */
	static var strNbStationsTrouvees = NSLocalizedString(" stations trouvées", comment: "strNbStationsTrouvees")
	static var strAucuneStationTrouvee = NSLocalizedString("Aucune station trouvée", comment: "strAucuneStationTrouvee")
	
	/* AddConso Popup if km is < than vehiclekm */
	static var strDateKMError = NSLocalizedString("La date du ravitaillement doit être ultérieure à la date d'achat", comment: "strDateKMError")
	
	/* Simple texts */
	static var strStationService = NSLocalizedString("Station Service", comment: "strStationService")
	
	/* Detail Station */
	static var strSignalementStationActionSheetTitle = NSLocalizedString("Que voulez-vous signaler pour ce carburant ?", comment: "strSignalementStationActionSheetTitle")
	static var strSignalementStationActionSheetChoice1 = NSLocalizedString("Mettre à jour le prix", comment: "strSignalementStationActionSheetChoice1")
	static var strSignalementStationActionSheetChoice2 = NSLocalizedString("Signaler une Pénurie", comment: "strSignalementStationActionSheetChoice2")
	
	/* Note de Frais */
	static var strReferenceNdF = NSLocalizedString("Référence", comment: "strReferenceNdF")
	static var strDateNdF = NSLocalizedString("Date de la mission", comment: "strDateNdF")
	
    /* Parking function disabled popup */
	static var messageParkingFunctionDisabled = NSLocalizedString("Votre connexion internet n'est pas stable. La fonction Parking a été désactivée pour cette session. Pour pouvoir la réutiliser, redémarrez l'application avec une connexion internet.", comment: "strParkingFunctionDisabled")
	
	/* Popup de suppression véhicule */
	static var deleteBtn = NSLocalizedString("Supprimer", comment: "deleteBtn")
	static var editBtn = NSLocalizedString("Details", comment: "editBtn")
	static var deleteCarAlertTitle = NSLocalizedString("Supprimer véhicule", comment: "deleteCarAlertTitle")
	static var deleteCarAlertMessage = NSLocalizedString("Attention ! Si vous supprimez cette voiture, vous supprimerez tous les ravitaillements associés. Etes-vous sûr de vouloir continuer ?", comment: "deleteCarAlertMessage")
	static var deleteCarAlertYes = NSLocalizedString("Oui", comment: "deleteCarAlertYes")
	static var deleteCarAlertNo = NSLocalizedString("Non", comment: "deleteCarAlertNo")
	static var confirmCarDeleteTitle = NSLocalizedString("Supprimé !", comment: "confirmCarDeleteTitle")
	static var confirmCarDeleteMessage = NSLocalizedString("La voiture et ses données associées ont bien été supprimés !", comment: "confirmCarDeleteToastMessage")
	
	static var noCarMessage = NSLocalizedString("Vous n'avez pas encore ajouté de véhicule. Touchez le bouton + pour en ajouter un.", comment: "noCarMessage")
	
	
	/* This popup is displayed when there is no car on the database */
	static var titleAddCar = NSLocalizedString("Saisir une véhicule", comment: "AddCarAlertTitle")
	static var messageAddCar = NSLocalizedString("Vous n'avez pas encore de véhicule. Voulez-vous en saisir un ?", comment: "AddCarAlertMessage")
	static var yesText = NSLocalizedString("Oui", comment: "AddCarAlertYesAnswer")
	static var noText = NSLocalizedString("Non", comment: "AddCarAlertNoAnswer")
	
	/* This popup is diplayed if the vehicle is not located so we cannot join it */
	static var titlePeuxPasRejoindreVehicule = NSLocalizedString("Oups", comment: "titlePeuxPasRejoindreVehicule")
	static var messagePeuxPasRejoindreVehicule = NSLocalizedString("Vous n'avez pas localisé votre véhicule. Veuillez marquer la position du véhicule pour le rejoindre.", comment: "messagePeuxPasRejoindreVehicule")
	
	/* BDD management popups */
	static var titleConfirmRestore = NSLocalizedString("Confirmer restauration", comment: "titleConfirmRestore")
	static var messageConfirmRestore = NSLocalizedString("Etes-vous sûr de vouloir restaurer vos données ? Cette restauration écrasera les données existantes", comment: "messageConfirmRestore")
	static var buttonYes = NSLocalizedString("Oui", comment: "buttonYes")
	static var buttonNo = NSLocalizedString("Non", comment: "buttonNo")
	
	static var titleRestoreDBSuccess = NSLocalizedString("Restauration réussie", comment: "titleRestoreDBSuccess")
	static var messageRestoreDBSuccess = NSLocalizedString("Les données de l'application ont bien été restaurées. Veuillez relancer l'application pour la prise en compte.", comment: "messageRestoreDBSuccess")
	static var buttonOK = NSLocalizedString("OK", comment: "buttonOK")
	
	static var titleRestoreDBError = NSLocalizedString("Erreur restauration", comment: "titleRestoreDBError")
	static var messageRestoreDBError = NSLocalizedString("Une erreur s'est produite lors de la restauration des données de l'application.", comment: "messageRestoreDBError")
	
	static var titleBackupNotExist = NSLocalizedString("Sauvegarde inexistante", comment: "titleBackupNotExist")
	static var messageBackupNotExist = NSLocalizedString("Aucune sauvegarde n'a été trouvée.", comment: "messageBackupNotExist")
	
	static var titleClearBackUps = NSLocalizedString("Attention", comment: "titleClearBackUps")
	static var messageClearBackUps = NSLocalizedString("Vous êtes sur le point d'effacer l'ensemble de vos sauvegardes. Etes-vous sûrs de vouloir continuer ?", comment: "messageClearBackUps")
	
	static var titleConfirmClearBackUps = NSLocalizedString("Dossier de sauvegarde vidé", comment: "titleConfirmClearBackUps")
	static var messageConfirmClearBackUps = NSLocalizedString("Le dossier de sauvegarde de l'application a bien été vidé!", comment: "messageConfirmClearBackUps")
	
	static var titleErrorClearBackUps = NSLocalizedString("Erreur d'effacement", comment: "titleErrorClearBackUps")
	static var messageErrorClearBackUps = NSLocalizedString("Une erreur s'est produite lors de l'effacement du dossier de sauvegarde", comment: "messageErrorClearBackUps")
	
	static var titleConfirmErase = NSLocalizedString("Confirmer effacement des données", comment: "titleConfirmErase")
	static var messageConfirmErase = NSLocalizedString("Etes-vous sûr de vouloir supprimer toutes les données de l'application ? Vous ne pourrez plus revenir en arrière.", comment: "messageConfirmErase")
	
	static var titleOKErase = NSLocalizedString("Données réinitialisées", comment: "titleOKErase")
	static var messageOKErase = NSLocalizedString("Toutes les données de l'application ont été effacées.", comment: "messageOKErase")
	
	static var titleSaveDBSuccess = NSLocalizedString("Sauvegarde réussie", comment: "titleSaveDBSuccess")
	static var messageSaveDBSuccess = NSLocalizedString("Les données de l'application ont bien été sauvegardées.", comment: "messagePeuxPasRejoindreVehicule")
	
	static var titleSaveDBError = NSLocalizedString("Erreur sauvegarde", comment: "titleSaveDBError")
	static var messageSaveDBError = NSLocalizedString("Une erreur s'est produite lors de la sauvegarde des données de l'application.", comment: "messageSaveDBError")
	
	/* Preferences configuration texts */
	static var lblDeviseAlertTitle = NSLocalizedString("Saisie de la devise", comment: "lblDeviseAlertTitle")
	static var alertDeviseMessage = NSLocalizedString("Saisir une devise", comment: "alertDeviseMessage")
	static var textFieldHint = NSLocalizedString("Devise", comment: "textFieldHint")
	
	static var lblDistanceAlertTitle = NSLocalizedString("Saisie de l'unité de distance", comment: "lblDistanceAlertTitle")
	static var alertDistanceMessage = NSLocalizedString("Saisir une unité de distance", comment: "alertDistanceMessage")
	static var textFieldDistanceHint = NSLocalizedString("Distance", comment: "textFieldDistanceHint")
	
	static var lblVolAlertTitle = NSLocalizedString("Saisie de l'unité de volume", comment: "lblVolAlertTitle")
	static var alertVolMessage = NSLocalizedString("Saisir une unité de volume", comment: "alertVolMessage")
	static var textFieldVolHint = NSLocalizedString("Unité de Volume", comment: "textFieldVolHint")
	
	static var lblFraisKMAlertTitle = NSLocalizedString("Frais kilométrique", comment: "lblFraisKMAlertTitle")
	static var lblFraisKMMessage = NSLocalizedString("Saisir le barême de frais kilométrique", comment: "lblFraisKMMessage")
	static var lblFraisKMHint = NSLocalizedString("€/km", comment: "lblFraisKMHint")
	
	/* Backups */
	/*static var titleBackupNotExist = NSLocalizedString("Sauvegarde inexistante", comment: "titleBackupNotExist")
	static var messageBackupNotExist = NSLocalizedString("Aucune sauvegarde n'a été trouvée.", comment: "messageBackupNotExist")*/
	static var strChargerSauvegarde = NSLocalizedString("Charger une sauvegarde", comment: "strChargerSauvegarde")
	static var strNommerSauvegarde = NSLocalizedString("Nommer la sauvegarde", comment: "strNommerSauvegarde")
	static var strMessageNommerSauvegarde = NSLocalizedString("Donnez un nom à votre sauvegarde (sans espaces ni caractères spéciaux)", comment: "strMessageNommerSauvegarde")
	
	/**/
	static var titleNomOperationNOK = NSLocalizedString("Champ Opération vide", comment: "titleNomOperationNOK")
	static var messageNomOperationNOK = NSLocalizedString("Veuillez renseigner une opération svp.", comment: "messageNomOperationNOK")
	
	static var  emptyOperationMessage = NSLocalizedString("Vous n'avez enregistré aucune prévision sur votre agenda pour le moment", comment: "emptyOperationMessage")
	static var  emptyFactureMessage = NSLocalizedString("Cette facture ne contient aucune opération d'entretien", comment: "emptyFactureMessage")
	
	/* Frais popups */
	static var deleteFraisAlertTitle = NSLocalizedString("Suppression frais", comment: "deleteConsoAlertTitle")
	static var deleteFraisAlertMessage = NSLocalizedString("Etes-vous sûr de vouloir supprimer la ligne sélectionnée ?", comment: "deleteConsoAlertMessage")
	static var deleteConsoAlertYes = NSLocalizedString("Oui", comment: "deleteConsoAlertYes")
	static var deleteConsoAlertNo = NSLocalizedString("Non", comment: "deleteConsoAlertNo")
	static var confirmConsoDelete = NSLocalizedString("La ligne a bien été supprimée de la base", comment: "confirmConsoDeleteConso")
	
	static var  vehicle = NSLocalizedString("Véhicule", comment: "vehicle")
	static var  TitleMyVehicle = NSLocalizedString("Pseudo", comment: "TitleMyVehiclePseudo")
	static var  labelSelectVehicle = NSLocalizedString("Selectionner un véhicule", comment: "labelSelectVehicle")
}
