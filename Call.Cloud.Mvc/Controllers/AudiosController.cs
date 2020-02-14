﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Mvc;

using Call.Cloud.Mvc.Models.Effectiveness;
using Call.Cloud.Mvc.App_Start.Extenciones;
using Call.Cloud.Mvc.Models.AudioVM;
using Call.Cloud.Logica;
using Call.Cloud.Modelo;
using System.Threading;
using System.Text;

/* Seguridad */
using Call.Cloud.Mvc.Models.Acount;
using Call.Cloud.Mvc.Controllers.Shared;
/* Fin Seguridad */

using Google.Cloud.Speech.V1;

namespace Call.Cloud.Mvc.Controllers
{
    public class AudiosController : ApplicationController<LogOnModel>
    {
        // GET: Audios
        public async Task<ActionResult> Audios(string respuesta = "")
        {
            LogOnModel sessionModel = GetLogOnSessionModel();
            if (sessionModel is null)
            {
                return RedirectToAction("Login_User");
            }
            else
            {
                AgentLogica ol = new AgentLogica();
                BusinessLogica business = new BusinessLogica();
                ViewBag.Mensaje = respuesta;

                var listabusiness = await business.RetrieveActive(new Business());
                var boss = await ol.RetrieveBoss(new Agent());
                var agent = await ol.RetrievAgent(new Agent());

                ViewData["Filtro_PK_Business"] = new SelectList(listabusiness);
                ViewData["Filtro_Fk_Boss"] = new SelectList(new[] { "(Selecciona)" });

                ViewData["Filtro_Fk_Boss"] = new SelectList(boss);
                ViewData["Filtro_PkAgent"] = new SelectList(new[] { "(Selecciona)" });

                return View(await CrearModelo(new AudioVm()));
            }
        }

        public async Task<ActionResult> GetElements(int pkbusiness=0)
        {
            AgentLogica ol = new AgentLogica();
            BusinessLogica business = new BusinessLogica();

            var listabusiness = await business.RetrieveActive(new Business());
            var boss = await ol.GetElementsForBusiness(pkbusiness);

            IEnumerable<Agent> elements = boss;
            if (elements == null)
                throw new ArgumentException("Business " + pkbusiness + " no es correcta");            

            return Json(elements, JsonRequestBehavior.AllowGet);
        }

        public async Task<ActionResult> GetElementsByBoss(int pkboss = 0)
        {
            AgentLogica ol = new AgentLogica();
            
            var boss = await ol.RetrieveBoss(new Agent());
            var agent = await ol.GetElementsForBoss(pkboss);

            IEnumerable<Agent> elements = agent;
            if (elements == null)
                throw new ArgumentException("Boss " + pkboss + " no es correcta");            

            return Json(elements, JsonRequestBehavior.AllowGet);
        }


        private async Task<ListasAudios> CrearModelo(AudioVm Item = null)
        {
            string respuesta = "";
            Audio r= new Audio();            
            AgentLogica ol = new AgentLogica();
            BusinessLogica business = new BusinessLogica();

            if (Item == null)
                Item = new AudioVm();           
         
            var datosAudios = await r.listar_audios(Item);
            var listabusiness = await business.RetrieveActive(new Business());
            var boss = await ol.RetrieveBoss(new Agent());
            var agent = await ol.RetrievAgent(new Agent());

            Session["mensaje"] = respuesta;
            ViewBag.Mensaje = respuesta;

            return new ListasAudios(Item, datosAudios, boss,agent,listabusiness);
        }

        public async Task<ActionResult> Buscar(AudioVm filtro)
        {                     
            return View("Grid", await CrearModelo(filtro));            
        }

        private async Task<ListaDetalleVM> CrearModelo1(AudioVm Item = null)
        {
            Audio r = new Audio(); 

            if (Item == null)
                Item = new AudioVm();
            var datosAudios = await r.listar_audios_detalle(Item);
            return new ListaDetalleVM(Item, datosAudios);
        }
        public async Task<ActionResult> Audios_Listar(AudioVm filtro)
        {
            return View("Grid", await  CrearModelo(filtro));
        }

          
        public async Task<ActionResult> Detalle_Audio1(AudioVm id)
        {
            Audio r = new Audio();
            var detalle_audio= await r.listar_audios_detalle(id);
            return View("Detalle_Audio", CrearModelo1(id));
        }

        [HttpGet]
        public async Task<ActionResult> Detalle_Audio(int id)
        {
            Audio r = new Audio();
          

            var item = (id == -1) ? new AudioVm () : (new AudioVm
            {
                pk_auido  = id
            });
             var list_detall_audio= await  r.listar_audios_detalle(item);
             return View(new ListaDetalleVM(item, list_detall_audio));
        }

        //Transcripcion de datos

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<ActionResult> transcriptarAudio()
        {
            var speech = SpeechClient.Create();
            var response = speech.Recognize(new RecognitionConfig()
            {
                Encoding = RecognitionConfig.Types.AudioEncoding.Linear16,
                SampleRateHertz = 16000,
                LanguageCode = "esp",
            }, RecognitionAudio.FromFile("D:/meperdonas.mp3"));

            StringBuilder cadena = new StringBuilder();

            foreach (var result in response.Results)
            {
                foreach (var alternative in result.Alternatives)
                {
                    cadena.Append(alternative.Transcript);
                }
            }
            ViewData["textoCad"] = cadena;

            return View("~/Audios/Audios.cshtml");
        }


    }
}