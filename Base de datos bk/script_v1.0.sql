CREATE DATABASE BD_QBOT
GO
USE [BD_QBOT]
GO
/****** Object:  User [admin]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [admin] FOR LOGIN [admin] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [anprrecog]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [anprrecog] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [audiopass]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [audiopass] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [dev]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [dev] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [facepreprocess]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [facepreprocess] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [facerecog]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [facerecog] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [facesgestures]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [facesgestures] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [ivr]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [ivr] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [mail]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [mail] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [objectrecog]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [objectrecog] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [sms]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [sms] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [tts]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [tts] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [videoanalytic]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [videoanalytic] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [videocapture]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [videocapture] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [videoeditor]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [videoeditor] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[videoeditor]
GO
/****** Object:  User [videogif]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [videogif] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [videomobileconversor]    Script Date: 12/02/2020 20:00:02 ******/
CREATE USER [videomobileconversor] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[dbo]
GO
ALTER ROLE [db_owner] ADD MEMBER [admin]
GO
ALTER ROLE [db_datareader] ADD MEMBER [audiopass]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [audiopass]
GO
ALTER ROLE [db_datareader] ADD MEMBER [videogif]
GO
ALTER ROLE [db_datawriter] ADD MEMBER [videogif]
GO
/****** Object:  Schema [videoeditor]    Script Date: 12/02/2020 20:00:03 ******/
CREATE SCHEMA [videoeditor]
GO
/****** Object:  UserDefinedFunction [dbo].[fc_CalculaResultadoXAnno]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fc_CalculaResultadoXAnno]
(
@pkAgent int,
@año varchar(9),
@pk_business int
)
returns decimal(8,2)
begin
		declare @result as decimal(8,2)

		set @result =
		(
		select
		avg(tempo3.Results) 
		from
		(
		    select
		    avg(tempo2.Results) as Results
		    from
		    (
		    select
		    convert(varchar(10),tempo.datecreated,112) as datecreated,
		    avg(tempo.Results) as Results,
		    tempo.[MONTH]
		    from
		    (
		    SELECT 
		    au.datecreated,
		    au.pk_audio,
		    ws.[pk_Mes],
		    ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,
		    case when ra.QuantityCall = 0 then null else SUM(ra.Results) end AS 'Results'
		    FROM ReportEffectivenessAgentMonth ra
		    inner join Agent ag
		    ON ra.PK_Agent=ag.PK_Agent inner join (SELECT  DISTINCT pk_mes,mes FROM Semana2016) ws
		    ON ra.Month= ws.MES
		    inner join Audio au on au.pk_audio = ra.pk_audio 
		    WHERE ra.PK_Agent=@pkAgent and ra.Year=@año --and ws.[pk_Mes] = @pk_mes
		    and  ag.pk_business = @pk_business
		    GROUP by ws.[pk_Mes],ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,ra.QuantityCall,
		    au.datecreated,au.pk_audio
		    ) as tempo
		    group by 
		    convert(varchar(10),tempo.datecreated,112),
		    tempo.[MONTH] 
		    )as tempo2
		    group by tempo2.[MONTH]
		    )as tempo3
		    )
		return @result;

end



GO
/****** Object:  UserDefinedFunction [dbo].[fc_CalculaResultadoXAnnoBoss]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fc_CalculaResultadoXAnnoBoss]
(
@pkBoss int,
@año varchar(9),
@pk_business int
)
returns decimal(8,2)
begin
		declare @result as decimal(8,2)

		set @result =
		(
		select --Promedio x Año
		avg(tempo3.Results) 
		from
		(
		    select -- PromedioxMes
		    avg(tempo2.Results) as Results
		    from
		    (
		    select --Promedio x Dia 
		    convert(varchar(10),tempo.datecreated,112) as datecreated,
		    avg(tempo.Results) as Results,
		    tempo.[MONTH]
		    from
		    (
		    SELECT 
		    au.datecreated,
		    au.pk_audio,
		    ws.[pk_Mes],
		    ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,
		    case when ra.QuantityCall = 0 then null else SUM(ra.Results) end AS 'Results'
		    FROM ReportEffectivenessAgentMonth ra
		    inner join Agent ag
		    ON ra.PK_Agent=ag.PK_Agent inner join (SELECT  DISTINCT pk_mes,mes FROM Semana2016) ws
		    ON ra.Month= ws.MES
		    inner join Audio au on au.pk_audio = ra.pk_audio 
		    WHERE 
		    ag.FK_Boss=@pkBoss and 
		    ra.Year=@año --and ws.[pk_Mes] = @pk_mes
		    and  ag.pk_business = @pk_business
		    GROUP by ws.[pk_Mes],ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,ra.QuantityCall,
		    au.datecreated,au.pk_audio
		    ) as tempo
		    group by 
		    convert(varchar(10),tempo.datecreated,112),
		    tempo.[MONTH] 
		    )as tempo2
		    group by tempo2.[MONTH]
		    )as tempo3
		    )
		return @result;

end



GO
/****** Object:  UserDefinedFunction [dbo].[fc_CalculaResultadoXAnnoBox]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create function [dbo].[fc_CalculaResultadoXAnnoBox]
(
@pkAgent int,
@año varchar(9),
@pk_business int
)
returns decimal(8,2)
begin
		declare @result as decimal(8,2)

		set @result =
		(
		select
		avg(tempo3.Results) 
		from
		(
		    select
		    avg(tempo2.Results) as Results
		    from
		    (
		    select
		    convert(varchar(10),tempo.datecreated,112) as datecreated,
		    avg(tempo.Results) as Results,
		    tempo.[MONTH]
		    from
		    (
		    SELECT 
		    au.datecreated,
		    au.pk_audio,
		    ws.[pk_Mes],
		    ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,
		    case when ra.QuantityCall = 0 then null else SUM(ra.Results) end AS 'Results'
		    FROM ReportEffectivenessAgentMonth ra
		    inner join Agent ag
		    ON ra.PK_Agent=ag.PK_Agent inner join (SELECT  DISTINCT pk_mes,mes FROM Semana2016) ws
		    ON ra.Month= ws.MES
		    inner join Audio au on au.pk_audio = ra.pk_audio 
		    WHERE ra.PK_Agent=@pkAgent and ra.Year=@año --and ws.[pk_Mes] = @pk_mes
		    and  ag.pk_business = @pk_business
		    GROUP by ws.[pk_Mes],ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,ra.QuantityCall,
		    au.datecreated,au.pk_audio
		    ) as tempo
		    group by 
		    convert(varchar(10),tempo.datecreated,112),
		    tempo.[MONTH] 
		    )as tempo2
		    group by tempo2.[MONTH]
		    )as tempo3
		    )
		return @result;

end



GO
/****** Object:  UserDefinedFunction [dbo].[fc_CalculaResultadoXAnnoXBossSeccion]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fc_CalculaResultadoXAnnoXBossSeccion]
(
@pkAgent int,
@año varchar(9),
@pk_business int,
@pk_section int
)
returns decimal(8,2)
begin
		declare @result as decimal(8,2)

		set @result =
		(
		select
		avg(tempo3.Results) 
		from
		(
		    select
		    avg(tempo2.Results) as Results
		    from
		    (
		    select
		    convert(varchar(10),tempo.datecreated,112) as datecreated,
		    avg(tempo.Results) as Results,
		    tempo.[MONTH]
		    from
		    (
		    SELECT 
		    au.datecreated,
		    au.pk_audio,
		    ws.[pk_Mes],
		    ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,
		    case when ra.QuantityCall = 0 then null else SUM(ra.Results) end AS 'Results'
		    FROM ReportEffectivenessAgentMonth ra
		    inner join Agent ag
		    ON ra.PK_Agent=ag.PK_Agent inner join (SELECT  DISTINCT pk_mes,mes FROM Semana2016) ws
		    ON ra.Month= ws.MES
		    inner join Audio au on au.pk_audio = ra.pk_audio 
		    WHERE 
		    ra.pk_section = @pk_section and
		    ra.PK_Agent=@pkAgent and ra.Year=@año --and ws.[pk_Mes] = @pk_mes
		    and  ag.pk_business = @pk_business
		    GROUP by ws.[pk_Mes],ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,ra.QuantityCall,
		    au.datecreated,au.pk_audio,ra.pk_section
		    ) as tempo
		    group by 
		    convert(varchar(10),tempo.datecreated,112),
		    tempo.[MONTH] 
		    )as tempo2
		    group by tempo2.[MONTH]
		    )as tempo3
		    )
		return @result;

end



GO
/****** Object:  UserDefinedFunction [dbo].[fc_CalculaResultadoXAnnoXSeccion]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fc_CalculaResultadoXAnnoXSeccion]
(
@pkAgent int,
@año varchar(9),
@pk_business int,
@pk_section int
)
returns decimal(8,2)
begin
		declare @result as decimal(8,2)

		set @result =
		(
		select
		avg(tempo3.Results) 
		from
		(
		    select
		    avg(tempo2.Results) as Results
		    from
		    (
		    select
		    convert(varchar(10),tempo.datecreated,112) as datecreated,
		    avg(tempo.Results) as Results,
		    tempo.[MONTH]
		    from
		    (
		    SELECT 
		    au.datecreated,
		    au.pk_audio,
		    ws.[pk_Mes],
		    ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,
		    case when ra.QuantityCall = 0 then null else SUM(ra.Results) end AS 'Results'
		    FROM ReportEffectivenessAgentMonth ra
		    inner join Agent ag
		    ON ra.PK_Agent=ag.PK_Agent inner join (SELECT  DISTINCT pk_mes,mes FROM Semana2016) ws
		    ON ra.Month= ws.MES
		    inner join Audio au on au.pk_audio = ra.pk_audio 
		    WHERE 
		    ra.pk_section = @pk_section and
		    ra.PK_Agent=@pkAgent and ra.Year=@año --and ws.[pk_Mes] = @pk_mes
		    and  ag.pk_business = @pk_business
		    GROUP by ws.[pk_Mes],ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,ra.QuantityCall,
		    au.datecreated,au.pk_audio,ra.pk_section
		    ) as tempo
		    group by 
		    convert(varchar(10),tempo.datecreated,112),
		    tempo.[MONTH] 
		    )as tempo2
		    group by tempo2.[MONTH]
		    )as tempo3
		    )
		return @result;

end



GO
/****** Object:  UserDefinedFunction [dbo].[fc_CalculaResultadoXMes]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE function [dbo].[fc_CalculaResultadoXMes]
(
@pkagent varchar(9),
@año varchar(9),
@pk_mes int
)
returns decimal(8,2)
begin
		declare @result as decimal(8,2)

		set @result =
		(
		select
		avg(tempo2.Results) as Results
		from
		(
		select
		convert(varchar(10),tempo.datecreated,112) as datecreated,
		avg(tempo.Results) as Results,
		tempo.[MONTH]
		from
		(
		SELECT 
		au.datecreated,
		au.pk_audio,
		ws.[pk_Mes],
		ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,
		case when ra.QuantityCall = 0 then null else SUM(ra.Results) end AS 'Results'
		FROM ReportEffectivenessAgentMonth ra
		inner join Agent ag
		ON ra.PK_Agent=ag.PK_Agent inner join (SELECT  DISTINCT pk_mes,mes FROM Semana2016) ws
		ON ra.Month= ws.MES
		inner join Audio au on au.pk_audio = ra.pk_audio 
		WHERE ra.PK_Agent=@pkagent and ra.Year=@año and ws.[pk_Mes] = @pk_mes
		GROUP by ws.[pk_Mes],ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,ra.QuantityCall,
		au.datecreated,au.pk_audio
		) as tempo
		group by 
		convert(varchar(10),tempo.datecreated,112),
		tempo.[MONTH] 
		)as tempo2
		group by tempo2.[MONTH]
		)
		return @result;

end



GO
/****** Object:  UserDefinedFunction [dbo].[fc_CalculaResultadoXMesxSeccion]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--select dbo.fc_CalculaResultadoXMesxSeccion('76','2017',)

CREATE function [dbo].[fc_CalculaResultadoXMesxSeccion]
(
@pkagent varchar(9),
@año varchar(9),
@pk_section int,
@pk_mes  int
)
returns decimal(8,2)
begin
		declare @result as decimal(8,2)

		set @result =
		(
		select
		avg(tempo2.Results) as Results
		from
		(
		select
		convert(varchar(10),tempo.datecreated,112) as datecreated,
		avg(tempo.Results) as Results,
		tempo.[MONTH]
		from
		(
		SELECT 
		au.datecreated,
		--au.pk_audio,
		ra.pk_section,
		ws.[pk_Mes],
		ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,
		case when ra.QuantityCall = 0 then null else SUM(ra.Results) end AS 'Results'
		FROM ReportEffectivenessAgentMonth ra
		inner join Agent ag
		ON ra.PK_Agent=ag.PK_Agent inner join (SELECT  DISTINCT pk_mes,mes FROM Semana2016) ws
		ON ra.Month= ws.MES
		inner join Audio au on au.pk_audio = ra.pk_audio 
		WHERE ra.PK_Agent=@pkagent and ra.Year=@año and ra.pk_section = @pk_section and ws.[pk_Mes] = @pk_mes 
		GROUP by ws.[pk_Mes],ra.PK_Agent,ra.nameAgent,ag.PK_Business,ra.Year,ra.MONTH,ra.QuantityCall,
		au.datecreated,
		ra.pk_section
		) as tempo
		group by 
		convert(varchar(10),tempo.datecreated,112),
		tempo.[MONTH] 
		)as tempo2
		group by tempo2.[MONTH]
		)
		return @result;

end



GO
/****** Object:  UserDefinedFunction [dbo].[fc_desencriptar]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  function [dbo].[fc_desencriptar]
(
@password varbinary(50)
)
returns varchar(50)
as
begin
declare @passw as varchar(50)
set @passw=DECRYPTBYPASSPHRASE('password',@password)
return @passw
end




GO
/****** Object:  UserDefinedFunction [dbo].[fc_incriptar]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create  function [dbo].[fc_incriptar]
(
 @password varchar(50)
)
returns varbinary(50)
as
begin
declare @pass as varbinary(50)
set @pass=ENCRYPTBYPASSPHRASE('password', @password)
return @pass
end




GO
/****** Object:  UserDefinedFunction [dbo].[fc_PercentagePhonemes]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fc_PercentagePhonemes](@v_wordRule varchar(50),@v_WordTranscription varchar(50))
returns decimal(8,2)
as begin 

declare @PercentageVocal decimal(8,2),
        @PercentageConsonant decimal(8,2),
		@PercentagePhonemes decimal(8,2),
		@PercentageXvocal decimal(8,2),
        @PercentageXconsonant decimal(8,2),
		@letter varchar(50),
		@accountant int=0,
		@accountantVocal int=0,
		@accountantConsonant int=0,
	    @ResultPercentagePhonemes decimal(8,2)=0.0,
		@sizeWordRule int=0,
		@va int=ASCII(UPPER('A')),
		@ve int=ASCII(UPPER('E')), 
		@vi int=ASCII(UPPER('I')),
		@vo int=ASCII(UPPER('O')),
		@vu int=ASCII(UPPER('U'))
	


 declare @accVpositonVocalA int,
         @QuantityRepetidVocalA int,
		 @accVpositonVocalE int,
         @QuantityRepetidVocalE int,
		 @accVpositonVocalI int,
         @QuantityRepetidVocalI int,
		 @accVpositonVocalO int,
         @QuantityRepetidVocalO int,
		 @accVpositonVocalU int,
         @QuantityRepetidVocalU int,
		 @AccVPositionVocalWordTranA int,
		 @QuantityRepetidVocalWordTranA int,
		 @AccVPositionVocalWordTranE int,
		 @QuantityRepetidVocalWordTranE int,
		 @AccVPositionVocalWordTranI int,
		 @QuantityRepetidVocalWordTranI int,
		 @AccVPositionVocalWordTranO int,
		 @QuantityRepetidVocalWordTranO int,
		 @AccVPositionVocalWordTranU int,
		 @QuantityRepetidVocalWordTranU int,
		 @WordTranTemp02 varchar(50),
		 @WordRuleTmp02 varchar(50),
		 @WordRuleTmp01 varchar(50),
         @WordTranTemp01 varchar(50)

 set @QuantityRepetidVocalA=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('a'), ''))) / len(UPPER('a'))
 set @QuantityRepetidVocalWordTranA=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('a'), ''))) / len(UPPER('a'))
 
 set @QuantityRepetidVocalE=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('e'), ''))) / len(UPPER('e'))
 set @QuantityRepetidVocalWordTranE=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(@v_WordTranscription, UPPER('e'), ''))) / len(UPPER('e'))
 
 set @QuantityRepetidVocalI=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('i'), ''))) / len(UPPER('i'))
 set @QuantityRepetidVocalWordTranI=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('i'), ''))) / len(UPPER('i'))
 
 set  @QuantityRepetidVocalO=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('o'), ''))) / len(UPPER('o'))
 set @QuantityRepetidVocalWordTranO=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('o'), ''))) / len(UPPER('o'))
 
 set  @QuantityRepetidVocalU=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('u'), ''))) / len(UPPER('u'))
 set @QuantityRepetidVocalWordTranU=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('u'), ''))) / len(UPPER('u'));

 declare @vcntVC int =0
 set @WordTranTemp02=UPPER(@v_WordTranscription)
 set @WordRuleTmp02= UPPER(@v_wordRule)
 ----- Vocal A

	if(@QuantityRepetidVocalWordTranA>1)
	  begin  
	       set @vcntVC=1
	       while(@vcntVC<@QuantityRepetidVocalWordTranA)
		   begin
		    set @vcntVC+=1
	        set @AccVPositionVocalWordTranA =patindex(UPPER('%a%'), UPPER(@WordTranTemp02));
            set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranA,1,'');
		   end
	        

	   end;
	 if(@QuantityRepetidVocalA>1)
		     begin
			   set @vcntVC=1
			   while(@vcntVC<@QuantityRepetidVocalA)
				begin
			      set @vcntVC+=1
			      set @accVpositonVocalA=patindex(UPPER('%a%'), UPPER(@WordRuleTmp02));
			      set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalA,1,'');
			    end
			 end

 ----. Fin de la vocal A;

 
 --- Vocal E
	 if(@QuantityRepetidVocalWordTranE>1)
	  begin 
	        set @vcntVC=1
            while (@vcntVC<@QuantityRepetidVocalWordTranE)
			 begin
			   set @vcntVC+=1
	           set @AccVPositionVocalWordTranE =patindex(UPPER('%e%'),UPPER(@WordTranTemp02));
               set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranE,1,'');
             end
	   end;

       if(@QuantityRepetidVocalE>1)
		   begin
               set @vcntVC=1
			   while (@vcntVC<@QuantityRepetidVocalE)
			   begin
			      set @vcntVC+=1
			      set @accVpositonVocalE=patindex(UPPER('%e%'), UPPER(@WordRuleTmp02));
			      set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalE,1,'');
			   end
		   end
 --. Fin de la vocal E
	   

   ----- Vocal i
	   if(@QuantityRepetidVocalWordTranI>1)
	  begin 
	     set @vcntVC=1
		 while(@vcntVC<@QuantityRepetidVocalWordTranI)
		  begin
		    set @vcntVC+=1
	        set @AccVPositionVocalWordTranI =patindex(UPPER('%i%'), UPPER(@WordTranTemp02));
            set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranI,1,'');
		 end
	   end;
	   if(@QuantityRepetidVocalI>1)
		     begin
			   set @vcntVC=1
			   while(@vcntVC<@QuantityRepetidVocalI)
			   begin
			     set @vcntVC+=1
			     set @accVpositonVocalI=patindex(UPPER('%i%'), UPPER(@WordRuleTmp02));
			     set @WordRuleTmp02=stuff(@WordRuleTmp02,@accVpositonVocalI,1,'');
			   end
			 end
 --. Fin de la vocal I


	-----vocal o
	   	   if(@QuantityRepetidVocalWordTranO>1)
	       begin 
	            set @vcntVC=1
				while(@vcntVC<@QuantityRepetidVocalWordTranO)
				begin
			    	set @vcntVC+=1
	                set @AccVPositionVocalWordTranO =patindex(UPPER('%o%'), UPPER(@WordTranTemp02));
                    set @WordTranTemp02 =stuff(@WordTranTemp02,@AccVPositionVocalWordTranO,1,'');
				end
	       end;
	       if(@QuantityRepetidVocalO>1)
		     begin
			   set @vcntVC=1
			   while(@vcntVC<@QuantityRepetidVocalO)
			   begin
			        set @vcntVC+=1
			        set @accVpositonVocalO=patindex(UPPER('%o%'), UPPER(@WordRuleTmp02));
			        set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalO,1,'');
			   end
			  end
 --. Fin de la vocal O;


	   	-----vocal U
	   	   if(@QuantityRepetidVocalWordTranU>1)
	          begin 
			     set @vcntVC=1
				 while(@vcntVC<@QuantityRepetidVocalWordTranU)
				 begin
				    set @vcntVC+=1
	                set @AccVPositionVocalWordTranU =patindex(UPPER('%u%'), UPPER(@WordTranTemp02));
                    set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranU,1,'');
                 end
	          end;
  
  if(@QuantityRepetidVocalU>1)
		     begin
			  set @vcntVC=1
			   while(@vcntVC<@QuantityRepetidVocalU)
			   begin 
			        set @vcntVC+=1
			        set @accVpositonVocalU=patindex(UPPER('%u%'),UPPER(@WordRuleTmp02));
			        set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalU,1,'');
			   end
			 end
 
set @sizeWordRule=LEN(@WordRuleTmp02)
select   top 1   @PercentageVocal=[PercentageVocal],@PercentageConsonant=[PercentageConsonant], @PercentagePhonemes=[PercentagePhonemes]from  [dbo].[EffectivenessPhonemes]

while(@accountant<@sizeWordRule)
begin
     set @accountant+=1
     set @letter=SUBSTRING(@WordRuleTmp02,@accountant,1)
	 if (ASCII(UPPER(@letter))in(@va,@ve,@vi,@vo,@vu))
	  begin
	 set @accountantVocal+=1

	  end
end;

set @accountant=0
set @accountantConsonant=@sizeWordRule-@accountantVocal
set @PercentageXvocal=Convert(decimal(8,2),1.00*@PercentageVocal/@accountantVocal)
set @PercentageXconsonant=Convert(decimal(8,2),1.00*@PercentageConsonant/@accountantConsonant)

set @WordRuleTmp01=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(@WordRuleTmp02),'B',''),'C',''),'D',''),'F','')
                  ,'G',''),'H',''),'J',''),'K',''),'L',''),'Ñ',''),'N',''),'P',''),'Q',''),'R',''),'S',''),'T',''),'V',''),'W',''),'X',''),'Y',''),'Z',''),'M','')

set @WordTranTemp01=REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(@WordTranTemp02),'B',''),'C',''),'D',''),'F','')
                  ,'G',''),'H',''),'J',''),'K',''),'L',''),'Ñ',''),'N',''),'P',''),'Q',''),'R',''),'S',''),'T',''),'V',''),'W',''),'X',''),'Y',''),'Z',''),'M','')

 
declare @VaccountantWordRuleTemp int= len(@WordRuleTmp01),
        @VaccountantWordTranscriptionTemp int=len(@WordTranTemp01),
		@VAccontWR int=0,
		@vAccontWRT int=0,
		@vLetter char(10)='',
        @vLetter2 char(10)='' 

while(@VAccontWR<@VaccountantWordRuleTemp)
   begin 
          set @VAccontWR +=1
          set @vLetter=SUBSTRING(@WordRuleTmp01,@VAccontWR,1) 
	      set @vAccontWRT=0
		           while(@vAccontWRT<@VaccountantWordTranscriptionTemp)
				   begin
				      set @vAccontWRT+=1
					  set @vLetter2=SUBSTRING(@WordTranTemp01,@vAccontWRT,1) 

					  if(@vLetter=@vLetter2)
					    begin
						      set  @ResultPercentagePhonemes+=@PercentageXvocal
							  break;
						end;

				   end;
   end;  
                                                      ---FIN DE EVALUACIÓN DE VOCALES 
-----------------------------------------------------------------------------------------------------------------------------------------------------------

 declare @vb int=ASCII(UPPER('B')),@accVpositonVocalB     int,@accVpositonVocalN     int,@AccVPositionVocalWordTranB int,@QuantityRepetidVocalWordTranB int,
         @vc int=ASCII(UPPER('C')),@QuantityRepetidVocalB int,@QuantityRepetidVocalN int,@AccVPositionVocalWordTranC int,@QuantityRepetidVocalWordTranC int,
		 @vd int=ASCII(UPPER('D')),@accVpositonVocalC     int,@accVpositonVocalP     int,@AccVPositionVocalWordTranD int,@QuantityRepetidVocalWordTranD int,
		 @vf int=ASCII(UPPER('F')),@QuantityRepetidVocalC int,@QuantityRepetidVocalP int,@AccVPositionVocalWordTranF int,@QuantityRepetidVocalWordTranF int,
		 @vg int=ASCII(UPPER('G')),@accVpositonVocalD     int,@accVpositonVocalQ     int,@AccVPositionVocalWordTranG int,@QuantityRepetidVocalWordTranG int,
		 @vh int=ASCII(UPPER('H')),@QuantityRepetidVocalD int,@QuantityRepetidVocalQ int,@AccVPositionVocalWordTranH int,@QuantityRepetidVocalWordTranH int,
		 @vj int=ASCII(UPPER('J')),@accVpositonVocalF     int,@accVpositonVocalS     int,@AccVPositionVocalWordTranJ int,@QuantityRepetidVocalWordTranJ int, 
		 @vk int=ASCII(UPPER('K')),@QuantityRepetidVocalF int,@QuantityRepetidVocalS int,@AccVPositionVocalWordTranK int,@QuantityRepetidVocalWordTranK int,
		 @vl int=ASCII(UPPER('L')),@accVpositonVocalG     int,@accVpositonVocalT     int,@AccVPositionVocalWordTranL int,@QuantityRepetidVocalWordTranL int,
		 @vñ int=ASCII(UPPER('Ñ')),@QuantityRepetidVocalG int,@QuantityRepetidVocalT int,@AccVPositionVocalWordTranÑ int,@QuantityRepetidVocalWordTranÑ int,
		 @vm int=ASCII(UPPER('M')),@accVpositonVocalH     int,@accVpositonVocalV     int,@AccVPositionVocalWordTranM int,@QuantityRepetidVocalWordTranM int,
		 @vn int=ASCII(UPPER('N')),@QuantityRepetidVocalH int,@QuantityRepetidVocalV int,@AccVPositionVocalWordTranN int,@QuantityRepetidVocalWordTranN int,
		 @vp int=ASCII(UPPER('P')),@accVpositonVocalJ     int,@accVpositonVocalW     int,@AccVPositionVocalWordTranP int,@QuantityRepetidVocalWordTranP int,
		 @vq int=ASCII(UPPER('Q')),@QuantityRepetidVocalJ int,@QuantityRepetidVocalW int,@AccVPositionVocalWordTranQ int,@QuantityRepetidVocalWordTranQ int,
		 @vr int=ASCII(UPPER('R')),@accVpositonVocalK     int,@accVpositonVocalX     int,@AccVPositionVocalWordTranR int,@QuantityRepetidVocalWordTranR int,
		 @vs int=ASCII(UPPER('S')),@QuantityRepetidVocalK int,@QuantityRepetidVocalX int,@AccVPositionVocalWordTranS int,@QuantityRepetidVocalWordTranS int,
		 @vt int=ASCII(UPPER('T')),@accVpositonVocalL     int,@accVpositonVocalY     int,@AccVPositionVocalWordTranT int,@QuantityRepetidVocalWordTranT int,
		 @vV int=ASCII(UPPER('V')),@QuantityRepetidVocalL int,@QuantityRepetidVocalY int,@AccVPositionVocalWordTranV int,@QuantityRepetidVocalWordTranV int,
		 @vw int=ASCII(UPPER('W')),@accVpositonVocalÑ     int,@accVpositonVocalZ     int,@AccVPositionVocalWordTranW int,@QuantityRepetidVocalWordTranW int,
		 @vx int=ASCII(UPPER('X')),@QuantityRepetidVocalÑ int,@QuantityRepetidVocalZ int,@AccVPositionVocalWordTranX int,@QuantityRepetidVocalWordTranX int,
		 @vy int=ASCII(UPPER('Y')),@accVpositonVocalM     int,@accVpositonVocalR     int,@AccVPositionVocalWordTranY int,@QuantityRepetidVocalWordTranY int,
		 @vz int=ASCII(UPPER('Z')),@QuantityRepetidVocalM int,@QuantityRepetidVocalR int,@AccVPositionVocalWordTranZ int,@QuantityRepetidVocalWordTranZ int;
     
 set @QuantityRepetidVocalB=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('b'), ''))) / len(UPPER('b'))
 set @QuantityRepetidVocalWordTranB=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('b'), ''))) / len(UPPER('b'))
 
 set @QuantityRepetidVocalC=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('c'), ''))) / len(UPPER('c'))
 set @QuantityRepetidVocalWordTranC=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('c'), ''))) / len(UPPER('c'))

 set @QuantityRepetidVocalD=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('d'), ''))) / len(UPPER('d'))
 set @QuantityRepetidVocalWordTranD=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('d'), ''))) / len(UPPER('d'))

 set @QuantityRepetidVocalF=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('f'), ''))) / len(UPPER('f'))
 set @QuantityRepetidVocalWordTranF=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('f'), ''))) / len(UPPER('f'))
 
 set @QuantityRepetidVocalG=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('g'), ''))) / len(UPPER('g'))
 set @QuantityRepetidVocalWordTranG=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('g'), ''))) / len(UPPER('g'))

 set @QuantityRepetidVocalH=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('h'), ''))) / len(UPPER('h'))
 set @QuantityRepetidVocalWordTranH=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('h'), ''))) / len(UPPER('h'))

 set @QuantityRepetidVocalJ=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('j'), ''))) / len(UPPER('j'))
 set @QuantityRepetidVocalWordTranJ=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('j'), ''))) / len(UPPER('j'))

 set @QuantityRepetidVocalK=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('k'), ''))) / len(UPPER('k'))
 set @QuantityRepetidVocalWordTranK=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('k'), ''))) / len(UPPER('k'))

 set @QuantityRepetidVocalL=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('l'), ''))) / len(UPPER('l'))
 set @QuantityRepetidVocalWordTranL=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('l'), ''))) / len(UPPER('l'))

 set @QuantityRepetidVocalÑ=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('ñ'), ''))) / len(UPPER('ñ'))
 set @QuantityRepetidVocalWordTranÑ=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('ñ'), ''))) / len(UPPER('ñ'))

 set @QuantityRepetidVocalM=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('m'), ''))) / len(UPPER('m'))
 set @QuantityRepetidVocalWordTranM=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('m'), ''))) / len(UPPER('m'))

 set @QuantityRepetidVocalN=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('n'), ''))) / len(UPPER('n'))
 set @QuantityRepetidVocalWordTranN=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('n'), ''))) / len(UPPER('n'))

 set @QuantityRepetidVocalP=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('p'), ''))) / len(UPPER('p'))
 set @QuantityRepetidVocalWordTranP=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('p'), ''))) / len(UPPER('p'))

 set @QuantityRepetidVocalQ=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('q'), ''))) / len(UPPER('q'))
 set @QuantityRepetidVocalWordTranQ=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('q'), ''))) / len(UPPER('q'))

 set @QuantityRepetidVocalR=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('r'), ''))) / len(UPPER('r'))
 set @QuantityRepetidVocalWordTranR=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('r'), ''))) / len(UPPER('r'))

 set @QuantityRepetidVocalS=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('s'), ''))) / len(UPPER('s'))
 set @QuantityRepetidVocalWordTranS=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('s'), ''))) / len(UPPER('s'))

 set @QuantityRepetidVocalT=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('t'), ''))) / len(UPPER('t'))
 set @QuantityRepetidVocalWordTranT=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('t'), ''))) / len(UPPER('t'))

 set @QuantityRepetidVocalV=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('v'), ''))) / len(UPPER('v'))
 set @QuantityRepetidVocalWordTranV=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('v'), ''))) / len(UPPER('v'))

 set @QuantityRepetidVocalW=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('w'), ''))) / len(UPPER('w'))
 set @QuantityRepetidVocalWordTranW=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('w'), ''))) / len(UPPER('w'))

 set @QuantityRepetidVocalX=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('x'), ''))) / len(UPPER('x'))
 set @QuantityRepetidVocalWordTranX=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('x'), ''))) / len(UPPER('x'))

 set @QuantityRepetidVocalY=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('y'), ''))) / len(UPPER('y'))
 set @QuantityRepetidVocalWordTranY=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('y'), ''))) / len(UPPER('y'))

 set @QuantityRepetidVocalZ=(len(UPPER(@v_wordRule)) - DATALENGTH(replace(UPPER(@v_wordRule), UPPER('z'), ''))) / len(UPPER('z'))
 set @QuantityRepetidVocalWordTranZ=(len(UPPER(@v_WordTranscription)) - DATALENGTH(replace(UPPER(@v_WordTranscription), UPPER('z'), ''))) / len(UPPER('z'))


 
 set @WordTranTemp02=UPPER(@v_WordTranscription)
 set @WordRuleTmp02= UPPER(@v_wordRule)

 ---Consonante  B ---- Iniciada
 	if(@QuantityRepetidVocalWordTranB>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranB)
		    begin
			   set @vcntVC+=1 
	           set @AccVPositionVocalWordTranB =patindex(UPPER('%b%'), UPPER(@WordTranTemp02));
               set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranB,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalB>1)
		begin
		   set @vcntVC=1
		   while(@vcntVC<@QuantityRepetidVocalB)
		     begin
			   set @vcntVC+=1 
			   set @accVpositonVocalB=patindex(UPPER('%b%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalB,1,'');
		     end
		end
 ---Consonante  B ---- Terminada

 
 ---Consonante  C ---- Iniciada
 	if(@QuantityRepetidVocalWordTranC>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranC)
		   begin
		       set @vcntVC+=1 
	           set @AccVPositionVocalWordTranC =patindex(UPPER('%c%'), UPPER(@WordTranTemp02));
               set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranC,1,'');
		   end
	   end;
	 if(@QuantityRepetidVocalC>1)
		 begin
			  set @vcntVC=1
			  while(@vcntVC<@QuantityRepetidVocalC)
			  begin
			     set @vcntVC+=1 
			     set @accVpositonVocalC=patindex(UPPER('%c%'), UPPER(@WordRuleTmp02));
			     set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalC,1,'');
			  end
		 end
 ---Consonante  C ---- Terminada


  ---Consonante  D ---- Iniciada
 	if(@QuantityRepetidVocalWordTranD>1)
	  begin 
	     set @vcntVC=1
		 while(@vcntVC<@QuantityRepetidVocalWordTranD)
		   begin
		      set @vcntVC+=1 
	          set @AccVPositionVocalWordTranD =patindex(UPPER('%d%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranD,1,'');
		   end
	   end;
	 if(@QuantityRepetidVocalD>1)
		begin
		   set @vcntVC=1
		   while(@vcntVC<@QuantityRepetidVocalD)
		    begin
		       set @vcntVC+=1
			   set @accVpositonVocalD=patindex(UPPER('%d%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalD,1,'');
		    end
		end
 ---Consonante  D ---- Terminada

   ---Consonante  F ---- Iniciada
 	if(@QuantityRepetidVocalWordTranF>1)
	  begin 
	       set @vcntVC=1
		   while(@vcntVC<@QuantityRepetidVocalWordTranF)
		   begin
		       set @vcntVC+=1
	           set @AccVPositionVocalWordTranF =patindex(UPPER('%f%'), UPPER(@WordTranTemp02));
               set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranF,1,'');
		   end
	   end;
	 if(@QuantityRepetidVocalF>1)
	   begin
			set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalF)
			 begin
			    set @vcntVC+=1
			    set @accVpositonVocalF=patindex(UPPER('%f%'), UPPER(@WordRuleTmp02));
			    set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalF,1,'');
			 end
	    end
 ---Consonante  F ---- Terminada


    ---Consonante  G ---- Iniciada
 	if(@QuantityRepetidVocalWordTranG>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranG)
		  begin
		     set @vcntVC+=1
	         set @AccVPositionVocalWordTranG =patindex(UPPER('%g%'), UPPER(@WordTranTemp02));
             set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranG,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalG>1)
	   begin
			  set @vcntVC=1
			  while(@vcntVC<@QuantityRepetidVocalG)
			  begin
			      set @vcntVC+=1
			      set @accVpositonVocalG=patindex(UPPER('%g%'), UPPER(@WordRuleTmp02));
			      set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalG,1,'');
			  end
	   end
 ---Consonante  G ---- Terminada

 ---Consonante  H ---- Iniciada
 	if(@QuantityRepetidVocalWordTranH>1)
	  begin 
	      set @vcntVC=1
	      while(@vcntVC<@QuantityRepetidVocalWordTranH)
	        begin
			   set @vcntVC+=1
	           set @AccVPositionVocalWordTranH =patindex(UPPER('%h%'), UPPER(@WordTranTemp02));
               set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranH,1,'');
		    end
	   end;
	 if(@QuantityRepetidVocalH>1)
	   begin
		   set @vcntVC=1
		   while(@vcntVC<@QuantityRepetidVocalH)
		    begin
			   set @vcntVC+=1
			   set @accVpositonVocalH=patindex(UPPER('%h%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalH,1,'');
			end
	   end
 ---Consonante  H ---- Terminada

 ---Consonante  J ---- Iniciada
 	if(@QuantityRepetidVocalWordTranJ>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranJ)
		   begin
		     set @vcntVC+=1
	         set @AccVPositionVocalWordTranJ =patindex(UPPER('%j%'), UPPER(@WordTranTemp02));
             set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranJ,1,'');
		   end
	   end;
	 if(@QuantityRepetidVocalJ>1)
		 begin
		   set @vcntVC=1
		   while(@vcntVC<@QuantityRepetidVocalJ)
		   begin
		       set @vcntVC+=1
			   set @accVpositonVocalJ=patindex(UPPER('%j%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalJ,1,'');
		   end 
		end
 ---Consonante  J ---- Terminada

  ---Consonante  K ---- Iniciada
 	if(@QuantityRepetidVocalWordTranK>1)
	  begin 
	      set @vcntVC=1
		   while(@vcntVC<@QuantityRepetidVocalWordTranK)
		   begin
		       set @vcntVC+=1
	           set @AccVPositionVocalWordTranK =patindex(UPPER('%k%'), UPPER(@WordTranTemp02));
               set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranK,1,'');
		   end
	   end;
	 if(@QuantityRepetidVocalK>1)
		begin
			set @vcntVC=1
			 while(@vcntVC<@QuantityRepetidVocalK)
			 begin
			   set @vcntVC+=1
			   set @accVpositonVocalK=patindex(UPPER('%k%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalK,1,'');
			 end
		end
 ---Consonante  K ---- Terminada

-----Consonante  L ---- Iniciada
 	if(@QuantityRepetidVocalWordTranL>1)
	  begin 
	      set @vcntVC=1
		  while (@vcntVC<@QuantityRepetidVocalWordTranL)
		  begin
		      set @vcntVC+=1
	          set @AccVPositionVocalWordTranL =patindex(UPPER('%l%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranL,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalL>1)
		begin
		    set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalL)
			begin
			   set @vcntVC+=1
			   set @accVpositonVocalL=patindex(UPPER('%l%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalL,1,'');
			end
		end
 ---Consonante  L ---- Terminada

 -----Consonante  Ñ ---- Iniciada
 	if(@QuantityRepetidVocalWordTranÑ>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranÑ)
		  begin
		      set @vcntVC+=1
	          set @AccVPositionVocalWordTranÑ =patindex(UPPER('%ñ%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranÑ,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalÑ>1)
	   begin
	       set @vcntVC=1
		   while(@vcntVC<@QuantityRepetidVocalÑ)
		   begin
			   set @vcntVC+=1
			   set @accVpositonVocalÑ=patindex(UPPER('%ñ%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalÑ,1,'');
			end
	   end
 ---Consonante  Ñ ---- Terminada

  -----Consonante  M ---- Iniciada
 	if(@QuantityRepetidVocalWordTranM>1)
	  begin 
	      set  @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranM)
		  begin 
		     set @vcntVC+=1
	         set @AccVPositionVocalWordTranM =patindex(UPPER('%M%'), UPPER(@WordTranTemp02));
             set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranM,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalM>1)
		begin
		    set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalM) 
			begin 
			   set @vcntVC+=1 
			   set @accVpositonVocalM=patindex(UPPER('%M%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalM,1,'');
			end
	    end
 ---Consonante  M ---- Terminada

  -----Consonante  N ---- Iniciada
 	if(@QuantityRepetidVocalWordTranN>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranN)
		  begin
		     set @vcntVC+=1 
	         set @AccVPositionVocalWordTranN =patindex(UPPER('%N%'), UPPER(@WordTranTemp02));
             set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranN,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalN>1)
		begin
			set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalN)
			begin
			   set @vcntVC+=1 
			   set @accVpositonVocalN=patindex(UPPER('%N%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalN,1,'');
			end
		end
 ---Consonante  N ---- Terminada

  -----Consonante  P ---- Iniciada
 	if(@QuantityRepetidVocalWordTranP>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranP)
		  begin  
		      set @vcntVC+=1
	          set @AccVPositionVocalWordTranP =patindex(UPPER('%p%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranP,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalP>1)
		begin
		    set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalP)
			begin
			   set @vcntVC+=1
			   set @accVpositonVocalP=patindex(UPPER('%p%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalP,1,'');
			end
		end
 ---Consonante  P ---- Terminada

   -----Consonante  Q ---- Iniciada
 	if(@QuantityRepetidVocalWordTranQ>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranQ)
		  begin
		     set @vcntVC+=1
	         set @AccVPositionVocalWordTranQ =patindex(UPPER('%q%'), UPPER(@WordTranTemp02));
             set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranQ,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalQ>1)
		begin
		    set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalQ)
			begin
			   set @vcntVC+=1
			   set @accVpositonVocalQ=patindex(UPPER('%q%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalQ,1,'');
			end
		end
 ---Consonante  Q ---- Terminada

   -----Consonante  R ---- Iniciada
 	if(@QuantityRepetidVocalWordTranR>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranR)
		  begin
		     set @vcntVC+=1
	         set @AccVPositionVocalWordTranR =patindex(UPPER('%r%'), UPPER(@WordTranTemp02));
             set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranR,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalR>1)
		begin
		    set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalR)
			begin
			   set @vcntVC+=1
			   set @accVpositonVocalR=patindex(UPPER('%r%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalR,1,'');
			end
		end
 ---Consonante  R ---- Terminada

    -----Consonante  S ---- Iniciada
 	if(@QuantityRepetidVocalWordTranS>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranS)
		  begin
		      set @vcntVC+=1
	          set @AccVPositionVocalWordTranS =patindex(UPPER('%s%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranS,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalS>1)
		begin
		    set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalS)
			 begin
			    set @vcntVC+=1
			    set @accVpositonVocalS=patindex(UPPER('%s%'), UPPER(@WordRuleTmp02));
			    set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalS,1,'');
			 end
		end
 ---Consonante  S ---- Terminada

     -----Consonantet T---- Iniciada
 	if(@QuantityRepetidVocalWordTranT>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranT)
		  begin  
		      set @vcntVC+=1
	          set @AccVPositionVocalWordTranT =patindex(UPPER('%T%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranT,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalT>1)
	   begin
	       set @vcntVC=1
		   while(@vcntVC<@QuantityRepetidVocalT)
		   begin
		       set @vcntVC+=1
			   set @accVpositonVocalT=patindex(UPPER('%t%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalT,1,'');
		   end
	   end
 ---Consonante  T ---- Terminada

      -----Consonantet V---- Iniciada
 	if(@QuantityRepetidVocalWordTranV>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranV)
		  begin
		      set @vcntVC+=1
	          set @AccVPositionVocalWordTranV =patindex(UPPER('%v%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranV,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalV>1)
		begin
		    set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalV)
			begin
			   set @vcntVC+=1
			   set @accVpositonVocalV=patindex(UPPER('%v%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalV,1,'');
			end
		end
 ---Consonante  V ---- Terminada

  -----Consonantet W---- Iniciada
 	if(@QuantityRepetidVocalWordTranW>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranW)
		  begin
		      set @vcntVC+=1
	          set @AccVPositionVocalWordTranW =patindex(UPPER('%w%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranW,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalW>1)
		begin
		    set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalW)
			begin
			    set @vcntVC+=1
			    set @accVpositonVocalW=patindex(UPPER('%w%'), UPPER(@WordRuleTmp02));
			    set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalW,1,'');
			end
		end
 ---Consonante  W ---- Terminada

   -----Consonantet X---- Iniciada
 	if(@QuantityRepetidVocalWordTranX>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranX)
		  begin
		      set @vcntVC+=1
	          set @AccVPositionVocalWordTranX =patindex(UPPER('%x%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranX,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalX>1)
		begin
			set @vcntVC=1
			while(@vcntVC<@QuantityRepetidVocalX)
			begin
			   set @vcntVC+=1
			   set @accVpositonVocalX=patindex(UPPER('%x%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalX,1,'');
			end
	    end
 ---Consonante  X ---- Terminada

   -----Consonantet Y---- Iniciada
 	if(@QuantityRepetidVocalWordTranY>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranY)
		  begin
		      set @vcntVC+=1
	          set @AccVPositionVocalWordTranY =patindex(UPPER('%y%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranY,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalY>1)
	   begin
	       set @vcntVC=1
		   while(@vcntVC<@QuantityRepetidVocalY)
		   begin
		       set @vcntVC+=1
			   set @accVpositonVocalY=patindex(UPPER('%y%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalY,1,'');
		   end
	   end
 ---Consonante  Y ---- Terminada


    -----Consonantet Z---- Iniciada
 	if(@QuantityRepetidVocalWordTranZ>1)
	  begin 
	      set @vcntVC=1
		  while(@vcntVC<@QuantityRepetidVocalWordTranZ)
		  begin
		      set @vcntVC+=1
	          set @AccVPositionVocalWordTranZ =patindex(UPPER('%z%'), UPPER(@WordTranTemp02));
              set @WordTranTemp02 =stuff(UPPER(@WordTranTemp02),@AccVPositionVocalWordTranZ,1,'');
		  end
	   end;
	 if(@QuantityRepetidVocalZ>1)
	   begin
	       set @vcntVC=1
		   while(@vcntVC<@QuantityRepetidVocalZ)
		   begin
		       set @vcntVC+=1
			   set @accVpositonVocalZ=patindex(UPPER('%z%'), UPPER(@WordRuleTmp02));
			   set @WordRuleTmp02=stuff(UPPER(@WordRuleTmp02),@accVpositonVocalZ,1,'');
		   end
	   end
 ---Consonante  Z ---- Terminada

 set @WordRuleTmp01= replace(replace(replace(replace(replace(UPPER(@WordRuleTmp02),'A',''),'E',''),'I',''),'O',''),'U','') 
 set @WordTranTemp01= replace(replace(replace(replace(replace(UPPER(@WordTranTemp02),'A',''),'E',''),'I',''),'O',''),'U','') 

 set  @VaccountantWordRuleTemp = len(@WordRuleTmp01);
 set  @VaccountantWordTranscriptionTemp =len(@WordTranTemp01);
 set  @VAccontWR =0
 set  @vAccontWRT =0
 set  @vLetter =''
 set  @vLetter2 ='' 

 while(@VAccontWR<@VaccountantWordRuleTemp)
   begin 
          set @VAccontWR +=1
          set @vLetter=SUBSTRING(@WordRuleTmp01,@VAccontWR,1) 
	      set @vAccontWRT=0

		           while(@vAccontWRT<@VaccountantWordTranscriptionTemp)
				   begin
				      set @vAccontWRT+=1
					  set @vLetter2=SUBSTRING(@WordTranTemp01,@vAccontWRT,1) 

					  if(@vLetter=@vLetter2)
					    begin
						      set  @ResultPercentagePhonemes+=@PercentageXconsonant
							  break;
						end;

				   end;
   end;  
       

 return isnull(@ResultPercentagePhonemes,0.0)
end





GO
/****** Object:  UserDefinedFunction [dbo].[fc_VerificacionV20092017]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fc_VerificacionV20092017]
  (@vAudioTrans int ,@vPK_Audio int,@vPK_Rule int ,@vATtext varchar(50),@PK_Enterprise int)
  returns varchar(max)
  AS Begin
 
    declare @v_output as varchar(max)
	declare @AudioTrancriptionValidRuleSinonimos as table(id Int identity(1,1),PK_AudioTranscription Int,text varchar(100))

	-- Variables WordRule
	declare @WordRuleKey varchar(100)='';
	-- Variables WordRule 
	Declare @PK_word Int
	
	Select @WordRuleKey= @WordRuleKey+ ' '+  word from wordrule  where pk_rule=@vPK_Rule and estado=1 order by [sequence] asc

	set @WordRuleKey = Ltrim(Rtrim(@WordRuleKey))

    Select @PK_word = pk_w from word where word = @WordRuleKey

	If(@PK_word is not null)
	Begin
				Declare @Table_SinomimosW Table(idS Int identity(1,1),wordSinonimo varchar(100));
				Insert into @Table_SinomimosW (wordSinonimo)			
				Select sinonimo from sinonimos where PK_Word =@PK_word;
				---sinonimos
				Declare @total_sinonmios  int ,@id_tableSionimos Int=0,@wordSinonimo varchar(100);
				DEclare @QuantityWordkeySinonimos Int

				--AudioTranscription ---
				Declare @Total_AudioTranscription Int , @id_AudioTranscription Int=0,@PK_AudioTranscription Int,@text_AudioTranscription varchar(100)='';

				Select @total_sinonmios= COUNT(*) from @Table_SinomimosW

				While(@id_tableSionimos<@total_sinonmios)
				Begin
						Set @id_tableSionimos+=1;

						Select @wordSinonimo=wordSinonimo from  @Table_SinomimosW where idS = @id_tableSionimos

						Set @QuantityWordkeySinonimos = (len(@wordSinonimo) - len(replace(@wordSinonimo,' ','')))+1;
						--9377 93778 93779
						insert into  @AudioTrancriptionValidRuleSinonimos(PK_AudioTranscription,text)
						Select top (@QuantityWordkeySinonimos)  PK_AudioTranscription,text from audioTranscription where PK_Audio = @vPK_Audio  And PK_AudioTranscription>= @vAudioTrans
						Order by PK_AudioTranscription asc	
							
								Select @text_AudioTranscription= @text_AudioTranscription +' '+text from @AudioTrancriptionValidRuleSinonimos
								
								Set @text_AudioTranscription =  RTRIM(LTRIM(@text_AudioTranscription))
								
								If(@wordSinonimo = @text_AudioTranscription)
								Begin
								        set @v_output = '0';

										 Select   @v_output = @v_output +','+ CAST(PK_AudioTranscription AS varchar(10)) from @AudioTrancriptionValidRuleSinonimos;
										  
										 set @v_output = subString (@v_output,3,len(@v_output))
										 Goto Etiqueta_AudioTranscription;
								End 									
				End
				Etiqueta_AudioTranscription:
	End
	return @v_output
End
GO
/****** Object:  UserDefinedFunction [dbo].[fc_VerificaPalabraRegla]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fc_VerificaPalabraRegla]
  (@vAudioTrans int ,@vPK_Audio int,@vPK_Rule int ,@vATtext varchar(50),@PK_Enterprise int)
  returns varchar(max)
  as begin

    	  /*************************** Variables *****************************/
	declare @FlagPalabraRegla varchar(max);

	declare @total_sinonmios  int ,@id_tableSionimos Int=0,@wordSinonimo varchar(100);
	declare @QuantityWordkeySinonimos Int
	declare @Total_AudioTranscription Int , @id_AudioTranscription Int=0;
	declare @PK_AudioTranscription Int,@text_AudioTranscription varchar(100)='';

     declare @WordRuleKey varchar(100)=''; 
	declare @PK_word Int
	declare @v_output as varchar(max)
	declare @AudioTrancriptionValidRuleSinonimos as table(id Int identity(1,1),PK_AudioTranscription Int,text varchar(100))
	Declare @Table_PalabraReglaW Table(idS Int identity(1,1),wordrule varchar(100));
	
	/************************** Fin de Variables *********************/
	/************************** Inicializar Variables ****************/
	set @FlagPalabraRegla = 0
	set @WordRuleKey = ''

	Select @WordRuleKey = @WordRuleKey+ ' '+  word from wordrule where pk_rule=@vPK_Rule and estado=1 order by [sequence] asc
	insert into @Table_PalabraReglaW values(@WordRuleKey)
	
	set @WordRuleKey = Ltrim(Rtrim(@WordRuleKey))

	Select @total_sinonmios= COUNT(*) from @Table_PalabraReglaW

	Select @wordSinonimo=wordrule from  @Table_PalabraReglaW ---where idS = @id_tableSionimos
	Set @QuantityWordkeySinonimos = (len(@wordSinonimo) - len(replace(@wordSinonimo,' ','')));
	
	declare @TranscriptionText varchar(100)='';

	While(@id_tableSionimos<@total_sinonmios)
	begin
		  Set @id_tableSionimos+=1;
		  
		  insert into  @AudioTrancriptionValidRuleSinonimos(PK_AudioTranscription,text)
		  select top (@QuantityWordkeySinonimos)  PK_AudioTranscription,text from audioTranscription 
		  where PK_Audio = @vPK_Audio  And PK_AudioTranscription>= @vAudioTrans
		  order by PK_AudioTranscription asc
		  		  
	end 

	Select @TranscriptionText = @TranscriptionText+ ' '+  [text] from @AudioTrancriptionValidRuleSinonimos  order by [id] asc
	set @TranscriptionText = Ltrim(Rtrim(@TranscriptionText))
	
	set @WordRuleKey = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(@WordRuleKey), 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u')
	set @TranscriptionText = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(@TranscriptionText), 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u') 

	if(@TranscriptionText = @WordRuleKey)
	begin
			 set @FlagPalabraRegla = '1' 

			 --select @pk_audiotranscription =  pk_audiotranscription 
			 --from audiotranscription where pk_audio = @vPK_Audio and [text]= @TranscriptionText
			 --insert into EffectivenessRule_Result values(1,2,3,4,5,'','',1)

		  --insert into  EffectivenessRule_Result
		  --select 1,2,3,4,5,startSecond,endSecond,1 from audioTranscription 
		  --where PK_Audio = @vPK_Audio  And PK_AudioTranscription = [text]
		  --order by PK_AudioTranscription asc
     end
	else
	begin 
			 set @FlagPalabraRegla = '0'
	end

	return @FlagPalabraRegla
	--return cast(@TranscriptionText as varchar(100)) + ' - ' + cast(@WordRuleKey as varchar(100)) + ' - ' + @vATtext
	--  return @pk_audiotranscription 
End
GO
/****** Object:  UserDefinedFunction [dbo].[fc_VerificaPalabraReglav2]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fc_VerificaPalabraReglav2]
  (@vAudioTrans int ,@vPK_Audio int,@vPK_Rule int ,@vATtext varchar(50),@PK_Enterprise int)
  returns varchar(max)
  as begin

    	  /*************************** Variables *****************************/
	declare @FlagPalabraRegla varchar(max);

	declare @total_sinonmios  int ,@id_tableSionimos Int=0,@wordSinonimo varchar(100);
	declare @QuantityWordkeySinonimos Int
	declare @Total_AudioTranscription Int , @id_AudioTranscription Int=0;
	declare @PK_AudioTranscription Int,@text_AudioTranscription varchar(100)='';

     declare @WordRuleKey varchar(100)=''; 
	declare @PK_word Int
	declare @v_output as varchar(max)
	declare @AudioTrancriptionValidRuleSinonimos as table(id Int identity(1,1),PK_AudioTranscription Int,text varchar(100))
	Declare @Table_PalabraReglaW Table(idS Int identity(1,1),wordrule varchar(100));
	
	/************************** Fin de Variables *********************/
	/************************** Inicializar Variables ****************/
	set @FlagPalabraRegla = 0
	set @WordRuleKey = ''

	Select @WordRuleKey = @WordRuleKey+ ' '+  word from wordrule where pk_rule=@vPK_Rule and estado=1 order by [sequence] asc
	insert into @Table_PalabraReglaW values(@WordRuleKey)
	
	set @WordRuleKey = Ltrim(Rtrim(@WordRuleKey))

	Select @total_sinonmios= COUNT(*) from @Table_PalabraReglaW

	Select @wordSinonimo=wordrule from  @Table_PalabraReglaW ---where idS = @id_tableSionimos
	Set @QuantityWordkeySinonimos = (len(@wordSinonimo) - len(replace(@wordSinonimo,' ','')));
	
	declare @TranscriptionText varchar(100)='';

	While(@id_tableSionimos<@total_sinonmios)
	begin
		  Set @id_tableSionimos+=1;
		  
		  insert into  @AudioTrancriptionValidRuleSinonimos(PK_AudioTranscription,text)
		  select top (@QuantityWordkeySinonimos)  PK_AudioTranscription,text from audioTranscription 
		  where PK_Audio = @vPK_Audio  And PK_AudioTranscription>= @vAudioTrans
		  order by PK_AudioTranscription asc
		  		  
	end 

	Select @TranscriptionText = @TranscriptionText+ ' '+  [text] from @AudioTrancriptionValidRuleSinonimos  order by [id] asc
	set @TranscriptionText = Ltrim(Rtrim(@TranscriptionText))
	
	set @WordRuleKey = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(@WordRuleKey), 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u')
	set @TranscriptionText = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(@TranscriptionText), 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u') 

	if(@TranscriptionText = @WordRuleKey)
	begin
			 set @FlagPalabraRegla = '1' 

			 set @v_output = '0';
			 select   @v_output = @v_output +','+ CAST(PK_AudioTranscription AS varchar(10)) from @AudioTrancriptionValidRuleSinonimos;
			 set @v_output = subString (@v_output,3,len(@v_output))
     
	end
	else
	begin 
			 set @FlagPalabraRegla = '0'
	end

	--return @FlagPalabraRegla
	--return cast(@TranscriptionText as varchar(100)) + ' - ' + cast(@WordRuleKey as varchar(100)) + ' - ' + @vATtext
	--return @TranscriptionText 
	return @v_output 
End
GO
/****** Object:  UserDefinedFunction [dbo].[fc_VerificaSinonimo]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fc_VerificaSinonimo]
  (@vAudioTrans int ,@vPK_Audio int,@vPK_Rule int ,@vATtext varchar(50),@PK_Enterprise int)
  returns varchar(max)
  AS Begin
 
    declare @v_output as varchar(max)
	declare @AudioTrancriptionValidRuleSinonimos as table(id Int identity(1,1),PK_AudioTranscription Int,text varchar(100))

	-- Variables WordRule
	declare @WordRuleKey varchar(100)='';
	-- Variables WordRule 
	Declare @PK_word Int
	
	Select @WordRuleKey= @WordRuleKey+ ' '+  word from wordrule  where pk_rule=@vPK_Rule and estado=1 order by [sequence] asc

	set @WordRuleKey = Ltrim(Rtrim(@WordRuleKey))

    /* Sacamos el Negocio */
    declare @FK_Business as int 
    set @FK_Business = (select top 1 FK_Business from Audio where pk_audio = @vPK_Audio)
    /****/ 
    Select @PK_word = pk_w from word where word = @WordRuleKey and pk_business = @FK_Business-- sacar por negocio.

	If(@PK_word is not null)
	Begin
				Declare @Table_SinomimosW Table(idS Int identity(1,1),wordSinonimo varchar(100));
				Insert into @Table_SinomimosW (wordSinonimo)			
				Select sinonimo from sinonimos where PK_Word =@PK_word;
				---sinonimos
				Declare @total_sinonmios  int ,@id_tableSionimos Int=0,@wordSinonimo varchar(100);
				DEclare @QuantityWordkeySinonimos Int

				--AudioTranscription ---
				Declare @Total_AudioTranscription Int , @id_AudioTranscription Int=0,@PK_AudioTranscription Int,@text_AudioTranscription varchar(100)='';

				Select @total_sinonmios= COUNT(*) from @Table_SinomimosW
				set @id_tableSionimos = 0
				While(@id_tableSionimos<@total_sinonmios)
				Begin
						Set @id_tableSionimos+=1;

						Select @wordSinonimo=wordSinonimo from  @Table_SinomimosW where idS = @id_tableSionimos

						Set @QuantityWordkeySinonimos = (len(@wordSinonimo) - len(replace(@wordSinonimo,' ','')))+1;
						--9377 93778 93779
						delete from @AudioTrancriptionValidRuleSinonimos --24092017
						insert into  @AudioTrancriptionValidRuleSinonimos(PK_AudioTranscription,text)
						Select top (@QuantityWordkeySinonimos)  PK_AudioTranscription,text from audioTranscription where PK_Audio = @vPK_Audio  And PK_AudioTranscription>= @vAudioTrans
						Order by PK_AudioTranscription asc	
							
								set @text_AudioTranscription = ''        --24092017
								Select @text_AudioTranscription= @text_AudioTranscription +' '+text from @AudioTrancriptionValidRuleSinonimos
								
								Set @text_AudioTranscription =  RTRIM(LTRIM(@text_AudioTranscription))
								
								set @wordSinonimo = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(@wordSinonimo), 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u')
								set @text_AudioTranscription = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(@text_AudioTranscription), 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u') 

								--print  @wordSinonimo 
								If(@wordSinonimo = @text_AudioTranscription)
								Begin
								        set @v_output = '0';

										 Select   @v_output = @v_output +','+ CAST(PK_AudioTranscription AS varchar(10)) from @AudioTrancriptionValidRuleSinonimos;
										  
										 set @v_output = subString (@v_output,3,len(@v_output))
										 Goto Etiqueta_AudioTranscription;
								End 									
				End
				Etiqueta_AudioTranscription:
	End
	return @v_output --@wordSinonimo + '/' + @text_AudioTranscription --@v_output
End
GO
/****** Object:  UserDefinedFunction [dbo].[fc_VerificaSinonimov2]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE function [dbo].[fc_VerificaSinonimov2]
  (@vAudioTrans int ,@vPK_Audio int,@vPK_Rule int ,@vATtext varchar(50),@PK_Enterprise int)
  returns varchar(max)
  AS Begin
 
    declare @v_output as varchar(max)
	declare @AudioTrancriptionValidRuleSinonimos as table(id Int identity(1,1),PK_AudioTranscription Int,text varchar(100))

	-- Variables WordRule
	declare @WordRuleKey varchar(100)='';
	-- Variables WordRule 
	Declare @PK_word Int
	
	Select @WordRuleKey= @WordRuleKey+ ' '+  word from wordrule  where pk_rule=@vPK_Rule and estado=1 order by [sequence] asc

	set @WordRuleKey = Ltrim(Rtrim(@WordRuleKey))

    Select @PK_word = pk_w from word where word = @WordRuleKey

	If(@PK_word is not null)
	Begin
				Declare @Table_SinomimosW Table(idS Int identity(1,1),wordSinonimo varchar(100));
				Insert into @Table_SinomimosW (wordSinonimo)			
				Select sinonimo from sinonimos where PK_Word =@PK_word;
				---sinonimos
				Declare @total_sinonmios  int ,@id_tableSionimos Int=0,@wordSinonimo varchar(100);
				DEclare @QuantityWordkeySinonimos Int

				--AudioTranscription ---
				Declare @Total_AudioTranscription Int , @id_AudioTranscription Int=0,@PK_AudioTranscription Int,@text_AudioTranscription varchar(100)='';

				Select @total_sinonmios= COUNT(*) from @Table_SinomimosW
				set @id_tableSionimos = 0
				While(@id_tableSionimos<@total_sinonmios)
				Begin
						Set @id_tableSionimos+=1;

						Select @wordSinonimo=wordSinonimo from  @Table_SinomimosW where idS = @id_tableSionimos

						Set @QuantityWordkeySinonimos = (len(@wordSinonimo) - len(replace(@wordSinonimo,' ','')))+1;
						--9377 93778 93779
						delete from @AudioTrancriptionValidRuleSinonimos --24092017
						insert into  @AudioTrancriptionValidRuleSinonimos(PK_AudioTranscription,text)
						Select top (@QuantityWordkeySinonimos)  PK_AudioTranscription,text from audioTranscription where PK_Audio = @vPK_Audio  And PK_AudioTranscription>= @vAudioTrans
						Order by PK_AudioTranscription asc	
							
								set @text_AudioTranscription = ''        --24092017
								Select @text_AudioTranscription= @text_AudioTranscription +' '+text from @AudioTrancriptionValidRuleSinonimos
								
								Set @text_AudioTranscription =  RTRIM(LTRIM(@text_AudioTranscription))
								
								set @wordSinonimo = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(@wordSinonimo), 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u')
								set @text_AudioTranscription = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(lower(@text_AudioTranscription), 'á', 'a'), 'é','e'), 'í', 'i'), 'ó', 'o'), 'ú','u') 

								--print  @wordSinonimo 
								If(@wordSinonimo = @text_AudioTranscription)
								Begin
								        set @v_output = '0';

										 Select   @v_output = @v_output +','+ CAST(PK_AudioTranscription AS varchar(10)) from @AudioTrancriptionValidRuleSinonimos;
										  
										 set @v_output = subString (@v_output,3,len(@v_output))
										 Goto Etiqueta_AudioTranscription;
								End 									
				End
				Etiqueta_AudioTranscription:
	End
	return @v_output --@wordSinonimo + '/' + @text_AudioTranscription --@v_output
End
GO
/****** Object:  UserDefinedFunction [dbo].[Split]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[Split] (@String nvarchar (4000), @Delimitador nvarchar (10)) 
                returns @ValueTable table ([Value] nvarchar(4000))
begin
 declare @NextString nvarchar(4000)
 declare @Pos int
 declare @NextPos int
 declare @CommaCheck nvarchar(1)
  
 --Inicializa
 set @NextString = ''
 set @CommaCheck = right(@String,1) 
  
 set @String = @String + @Delimitador
  
 --Busca la posición del primer delimitador
 set @Pos = charindex(@Delimitador,@String)
 set @NextPos = 1
  
 --Itera mientras exista un delimitador en el string
 while (@pos <>  0)  
 begin
  set @NextString = substring(@String,1,@Pos - 1)
  
  insert into @ValueTable ( [Value]) Values (@NextString)
  
  set @String = substring(@String,@pos +1,len(@String))
   
  set @NextPos = @Pos
  set @pos  = charindex(@Delimitador,@String)
 end
  
 return
end
GO
/****** Object:  Table [dbo].[Account]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Account](
	[AccountId] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[AccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Agent]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Agent](
	[PK_Agent] [int] IDENTITY(1,1) NOT NULL,
	[firstNAme] [nvarchar](500) NULL,
	[lastName] [nvarchar](500) NULL,
	[PK_Business] [int] NULL,
	[DNI] [varchar](8) NULL,
	[Mail] [varchar](100) NULL,
	[CodInt] [varchar](20) NULL,
	[FK_Boss] [int] NULL,
	[level] [int] NULL,
	[estado] [int] NULL,
	[Create_Date] [datetime] NULL,
	[Update_Date] [datetime] NULL,
	[Delete_Date] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AlertEmail]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AlertEmail](
	[PK_AlertEmail] [int] IDENTITY(1,1) NOT NULL,
	[PK_Business] [int] NULL,
	[PK_Boss] [int] NULL,
	[EmailOutput] [varchar](100) NULL,
	[EmailIntPut] [varchar](100) NULL,
	[PK_Agent] [int] NULL,
	[PK_Audio] [int] NULL,
	[Quantity] [int] NULL,
	[Wordtext] [varchar](1000) NULL,
	[Datecreated] [datetime] NULL,
	[stateAlertEmail] [int] NULL,
 CONSTRAINT [PK__AlertEma__D77A2F3544EA3301] PRIMARY KEY CLUSTERED 
(
	[PK_AlertEmail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AllErrorsAudio]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AllErrorsAudio](
	[Errorkey] [int] IDENTITY(1,1) NOT NULL,
	[madeby] [nvarchar](max) NULL,
	[PK_Audio] [int] NULL,
	[errNumber] [nvarchar](max) NULL,
	[errSeverity] [nvarchar](max) NULL,
	[errState] [nvarchar](max) NULL,
	[errProcedure] [nvarchar](max) NULL,
	[errLine] [nvarchar](max) NULL,
	[errMessage] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[Errorkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Audio]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Audio](
	[PK_audio] [int] IDENTITY(1,1) NOT NULL,
	[seconds] [int] NOT NULL,
	[status] [int] NOT NULL,
	[dateCreated] [datetime] NOT NULL,
	[dateInclude] [datetime] NULL,
	[FK_node] [int] NOT NULL,
	[filesize] [real] NULL,
	[transcription] [nvarchar](max) NULL,
	[AudioFreq] [int] NULL,
	[taskAudiothumbnail] [int] NULL,
	[taskAudioMp3] [int] NULL,
	[taskAudioTranscriptor] [int] NULL,
	[fileName] [nvarchar](max) NULL,
	[dirName] [nvarchar](max) NULL,
	[FK_Speech] [int] NULL,
	[FK_Agent] [int] NULL,
	[FK_Call] [int] NULL,
	[fileNamewav] [nvarchar](max) NULL,
	[dirNamewav] [nvarchar](max) NULL,
	[performance] [int] NULL,
	[fileNameMp3Ecualized] [nvarchar](max) NULL,
	[dirNameMp3Ecualized] [nvarchar](max) NULL,
	[fileNameWavEcualized] [nvarchar](max) NULL,
	[dirNameWavEcualized] [nvarchar](max) NULL,
	[state] [int] NULL,
	[stateWhiteList] [int] NULL,
	[stateBlackList] [int] NULL,
	[stateEffectiveness] [int] NULL,
	[StateWhiteError] [int] NULL,
	[StateBlackListError] [int] NULL,
	[FK_Business] [int] NULL,
	[stateAlertEmail] [int] NULL,
 CONSTRAINT [PK_Audio] PRIMARY KEY CLUSTERED 
(
	[PK_audio] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[AudioTranscription]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AudioTranscription](
	[PK_AudioTranscription] [int] IDENTITY(1,1) NOT NULL,
	[startSecond] [real] NULL,
	[endSecond] [real] NULL,
	[duration] [real] NULL,
	[text] [nvarchar](500) NULL,
	[PK_Audio] [int] NULL,
	[state] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[blackList]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[blackList](
	[pk] [int] IDENTITY(1,1) NOT NULL,
	[word] [nvarchar](200) NULL,
	[Enterprise] [int] NULL,
	[estado] [int] NULL,
	[Create_Date] [datetime] NULL,
	[Update_Date] [datetime] NULL,
	[Delete_Date] [datetime] NULL,
	[Business] [int] NULL,
 CONSTRAINT [PK_blackList] PRIMARY KEY CLUSTERED 
(
	[pk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[blackList_Detail]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[blackList_Detail](
	[pkdetail] [int] IDENTITY(1,1) NOT NULL,
	[word] [varchar](max) NULL,
	[Composition] [int] NULL,
	[order] [int] NULL,
	[estado] [int] NULL,
	[Create_Date] [datetime] NULL,
	[Update_Date] [datetime] NULL,
	[Delete_Date] [datetime] NULL,
 CONSTRAINT [PK__blackLis__DEEA691D20C1E124] PRIMARY KEY CLUSTERED 
(
	[pkdetail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Business]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business](
	[PK_Business] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](500) NULL,
	[PK_SubOffice] [int] NULL,
	[estado] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL,
	[active] [int] NULL,
 CONSTRAINT [PK_Business] PRIMARY KEY CLUSTERED 
(
	[PK_Business] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Business_Detail]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Business_Detail](
	[pkbusinessDetail] [int] IDENTITY(1,1) NOT NULL,
	[PK_Business] [int] NULL,
	[name] [varchar](500) NULL,
	[PK_SubOffice] [int] NULL,
	[estado] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Call]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Call](
	[PK_Call] [int] IDENTITY(1,1) NOT NULL,
	[PK_Business] [int] NULL,
	[dateInclude] [smalldatetime] NULL,
	[name] [nvarchar](50) NULL,
	[number_in] [nvarchar](20) NULL,
	[number_out] [nvarchar](20) NULL,
	[typecall] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Category]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[PK_Cat] [int] NOT NULL,
	[name] [varchar](300) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Enterprise]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Enterprise](
	[PK_Enterprise] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](50) NULL,
	[estado] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EnterpriseFTP]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EnterpriseFTP](
	[PK_ftp] [int] IDENTITY(1,1) NOT NULL,
	[PK_Enterprise] [int] NULL,
	[Server] [varchar](20) NULL,
	[Port] [varchar](10) NULL,
	[Folder] [varchar](50) NULL,
	[Username] [varchar](50) NULL,
	[Password] [varchar](50) NULL,
 CONSTRAINT [PK_EnterpriseFTP] PRIMARY KEY CLUSTERED 
(
	[PK_ftp] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LOGIN]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LOGIN](
	[pk_usuario] [int] IDENTITY(1,1) NOT NULL,
	[Name_user] [varchar](50) NULL,
	[usuario] [varchar](40) NOT NULL,
	[Password] [varchar](50) NOT NULL,
	[email] [varchar](40) NULL,
	[pk_enterprise] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Office]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Office](
	[PK_Office] [int] IDENTITY(1,1) NOT NULL,
	[nameOffice] [nvarchar](500) NULL,
	[PK_Enterprise] [int] NULL,
	[estado] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL,
 CONSTRAINT [PK_Office] PRIMARY KEY CLUSTERED 
(
	[PK_Office] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[RAudio]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[RAudio](
	[PK_audio] [int] IDENTITY(1,1) NOT NULL,
	[seconds] [int] NOT NULL,
	[status] [int] NOT NULL,
	[dateCreated] [datetime] NOT NULL,
	[dateInclude] [datetime] NULL,
	[FK_node] [int] NOT NULL,
	[filesize] [int] NULL,
	[transcription] [nvarchar](max) NULL,
	[AudioFreq] [int] NULL,
	[taskAudiothumbnail] [int] NULL,
	[taskAudioMp3] [int] NULL,
	[taskAudioTranscriptor] [int] NULL,
	[fileName] [nvarchar](max) NULL,
	[dirName] [nvarchar](max) NULL,
	[FK_Speech] [int] NULL,
	[FK_Agent] [int] NULL,
	[FK_Call] [int] NULL,
	[fileNamewav] [nvarchar](max) NULL,
	[dirNamewav] [nvarchar](max) NULL,
	[performance] [int] NULL,
	[fileNameMp3Ecualized] [nvarchar](max) NULL,
	[dirNameMp3Ecualized] [nvarchar](max) NULL,
	[fileNameWavEcualized] [nvarchar](max) NULL,
	[dirNameWavEcualized] [nvarchar](max) NULL,
	[state] [int] NULL,
	[stateWhiteList] [int] NULL,
	[stateBlackList] [int] NULL,
	[stateEffectiveness] [int] NULL,
	[StateWhiteError] [int] NULL,
	[StateBlackListError] [int] NULL,
	[FK_Business] [int] NULL,
	[stateAlertEmail] [int] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rule]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rule](
	[PK_Rule] [int] IDENTITY(1,1) NOT NULL,
	[PK_Section] [int] NULL,
	[name] [varchar](300) NULL,
	[time_rule] [numeric](6, 4) NULL,
	[weight] [numeric](5, 1) NULL,
	[estado] [nchar](10) NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Rule_Detail]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Rule_Detail](
	[pkRule_Detail] [int] IDENTITY(1,1) NOT NULL,
	[PK_Rule] [int] NULL,
	[PK_Section] [int] NULL,
	[name] [varchar](300) NULL,
	[time_rule] [numeric](6, 4) NULL,
	[wieght] [numeric](5, 1) NULL,
	[estado] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Section]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Section](
	[PK_Section] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](300) NULL,
	[descripcion] [varchar](max) NULL,
	[PK_Speech] [int] NULL,
	[weight] [numeric](5, 2) NULL,
	[TMO] [numeric](5, 2) NULL,
	[estado] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL,
 CONSTRAINT [PK_Section] PRIMARY KEY CLUSTERED 
(
	[PK_Section] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Section_Detail]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Section_Detail](
	[pkSectionDetail] [int] IDENTITY(1,1) NOT NULL,
	[PK_Section] [int] NULL,
	[name] [varchar](300) NULL,
	[descripcion] [varchar](max) NULL,
	[PK_Speech] [int] NULL,
	[weight] [numeric](5, 2) NULL,
	[TMO] [numeric](5, 2) NULL,
	[estado] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Sinonimos]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Sinonimos](
	[PK] [int] IDENTITY(1,1) NOT NULL,
	[PK_word] [int] NOT NULL,
	[sinonimo] [varchar](50) NULL,
 CONSTRAINT [PK_Sinonimos] PRIMARY KEY CLUSTERED 
(
	[PK] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Speech]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Speech](
	[PK_Speech] [int] IDENTITY(1,1) NOT NULL,
	[name] [varchar](350) NULL,
	[description] [varchar](max) NULL,
	[FK_business] [int] NULL,
	[estado] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_Speech] PRIMARY KEY CLUSTERED 
(
	[PK_Speech] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Speech_Detalle]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Speech_Detalle](
	[PkDetalle_Speech] [int] IDENTITY(1,1) NOT NULL,
	[PkSpeech] [int] NULL,
	[name] [varchar](350) NULL,
	[descripcion] [varchar](2000) NULL,
	[fk_business] [int] NULL,
	[estado] [int] NULL,
	[CreatedDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[SubOffice]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SubOffice](
	[PK_SubOffice] [int] IDENTITY(1,1) NOT NULL,
	[nameSubOffice] [varchar](300) NULL,
	[PK_Office] [int] NULL,
	[estado] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL,
 CONSTRAINT [PK_SubOffice] PRIMARY KEY CLUSTERED 
(
	[PK_SubOffice] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TimeAgent]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TimeAgent](
	[id] [int] NOT NULL,
	[name] [varchar](100) NOT NULL,
	[timeready] [int] NOT NULL,
	[timecall] [int] NOT NULL,
	[timebreak] [int] NOT NULL,
	[acw] [int] NOT NULL,
	[fec_reg] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[whiteList]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[whiteList](
	[PK_word] [int] IDENTITY(1,1) NOT NULL,
	[word] [varchar](200) NULL,
	[Porcentaje] [decimal](5, 2) NULL,
	[EnterPrise] [int] NULL,
	[estado] [int] NULL,
	[Create_Date] [datetime] NULL,
	[Update_Date] [datetime] NULL,
	[Delete_Date] [datetime] NULL,
 CONSTRAINT [PK_whiteList] PRIMARY KEY CLUSTERED 
(
	[PK_word] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[whiteList_Detail]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[whiteList_Detail](
	[pk_word_detail] [int] IDENTITY(1,1) NOT NULL,
	[word] [varchar](200) NULL,
	[Composition] [int] NULL,
	[order] [int] NULL,
	[estado] [int] NULL,
	[Create_Date] [datetime] NULL,
	[Update_Date] [datetime] NULL,
	[Delete_Date] [datetime] NULL,
 CONSTRAINT [PK_whiteList_Detail] PRIMARY KEY CLUSTERED 
(
	[pk_word_detail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Word]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Word](
	[PK_W] [int] IDENTITY(1,1) NOT NULL,
	[word] [varchar](50) NULL,
	[PK_Enterprise] [int] NULL,
	[pk_business] [int] NULL,
 CONSTRAINT [PK_Word] PRIMARY KEY CLUSTERED 
(
	[PK_W] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 100) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WordRule]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WordRule](
	[PK_WordRule] [int] IDENTITY(1,1) NOT NULL,
	[PK_Rule] [int] NULL,
	[word] [varchar](100) NULL,
	[Fk_AudioTranscription] [int] NULL,
	[sequence] [int] NULL,
	[time_word] [numeric](6, 4) NULL,
	[weight] [numeric](5, 2) NULL,
	[estado] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
	[DeleteDate] [datetime] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[WordRule_Detail]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[WordRule_Detail](
	[pkWordRule_Detail] [int] IDENTITY(1,1) NOT NULL,
	[PK_audio] [int] NULL,
	[PK_WordRule] [int] NULL,
	[PK_Rule] [int] NULL,
	[word] [varchar](100) NULL,
	[sequence] [int] NULL,
	[time_word] [numeric](6, 4) NULL,
	[weight] [numeric](5, 2) NULL,
	[estado] [int] NULL,
	[CreateDate] [datetime] NULL,
	[UpdateDate] [datetime] NULL,
 CONSTRAINT [PK_WordRule_Detail] PRIMARY KEY CLUSTERED 
(
	[pkWordRule_Detail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Agent] ADD  CONSTRAINT [DF_Agent_level]  DEFAULT ((0)) FOR [level]
GO
ALTER TABLE [dbo].[Agent] ADD  CONSTRAINT [DF_Agent_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Agent] ADD  CONSTRAINT [DF_Agent_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[Agent] ADD  CONSTRAINT [DF_Agent_Update_Date]  DEFAULT ('1900-01-01 00:00:00') FOR [Update_Date]
GO
ALTER TABLE [dbo].[Agent] ADD  CONSTRAINT [DF_Agent_Delete_Date]  DEFAULT ('1900-01-01 00:00:00') FOR [Delete_Date]
GO
ALTER TABLE [dbo].[AlertEmail] ADD  CONSTRAINT [DF_AlertEmail_Datecreated]  DEFAULT (getdate()) FOR [Datecreated]
GO
ALTER TABLE [dbo].[AlertEmail] ADD  CONSTRAINT [DF_AlertEmail_stateAlertEmail]  DEFAULT ((0)) FOR [stateAlertEmail]
GO
ALTER TABLE [dbo].[Audio] ADD  CONSTRAINT [DF_Audio_dateCreated]  DEFAULT (getdate()) FOR [dateCreated]
GO
ALTER TABLE [dbo].[Audio] ADD  CONSTRAINT [DF_Audio_state]  DEFAULT ((0)) FOR [state]
GO
ALTER TABLE [dbo].[Audio] ADD  CONSTRAINT [DF_Audio_stateWhiteList]  DEFAULT ((0)) FOR [stateWhiteList]
GO
ALTER TABLE [dbo].[Audio] ADD  CONSTRAINT [DF_Audio_stateBlackList]  DEFAULT ((0)) FOR [stateBlackList]
GO
ALTER TABLE [dbo].[Audio] ADD  CONSTRAINT [DF_Audio_stateEffectiveness]  DEFAULT ((0)) FOR [stateEffectiveness]
GO
ALTER TABLE [dbo].[Audio] ADD  CONSTRAINT [DF_Audio_StateError]  DEFAULT ((0)) FOR [StateWhiteError]
GO
ALTER TABLE [dbo].[Audio] ADD  CONSTRAINT [DF_Audio_StateBlackListError]  DEFAULT ((0)) FOR [StateBlackListError]
GO
ALTER TABLE [dbo].[Audio] ADD  CONSTRAINT [DF_Audio_stateAlertEmail]  DEFAULT ((0)) FOR [stateAlertEmail]
GO
ALTER TABLE [dbo].[AudioTranscription] ADD  CONSTRAINT [DF_AudioTranscription_state]  DEFAULT ((0)) FOR [state]
GO
ALTER TABLE [dbo].[blackList] ADD  CONSTRAINT [DF_blackList_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[blackList] ADD  CONSTRAINT [DF_blackList_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[blackList] ADD  CONSTRAINT [DF_blackList_Update_Date]  DEFAULT ('1900-01-01 00:00:00') FOR [Update_Date]
GO
ALTER TABLE [dbo].[blackList] ADD  CONSTRAINT [DF_blackList_Delete_Date]  DEFAULT ('1900-01-01 00:00:00') FOR [Delete_Date]
GO
ALTER TABLE [dbo].[blackList_Detail] ADD  CONSTRAINT [DF_blackList_Detail_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[blackList_Detail] ADD  CONSTRAINT [DF_blackList_Detail_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[blackList_Detail] ADD  CONSTRAINT [DF_blackList_Detail_Update_Date]  DEFAULT ('1900-01-01 00:00:00') FOR [Update_Date]
GO
ALTER TABLE [dbo].[blackList_Detail] ADD  CONSTRAINT [DF_blackList_Detail_Delete_Date]  DEFAULT ('1900-01-01 00:00:00') FOR [Delete_Date]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_DeleteDate]  DEFAULT ('1900-01-01 00:00:00') FOR [DeleteDate]
GO
ALTER TABLE [dbo].[Business] ADD  CONSTRAINT [DF_Business_active]  DEFAULT ((1)) FOR [active]
GO
ALTER TABLE [dbo].[Business_Detail] ADD  CONSTRAINT [DF_Business_Detail_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Business_Detail] ADD  CONSTRAINT [DF_Business_Detail_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Business_Detail] ADD  CONSTRAINT [DF_Business_Detail_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[Call] ADD  CONSTRAINT [DF_Call_typecall]  DEFAULT ((0)) FOR [typecall]
GO
ALTER TABLE [dbo].[Office] ADD  CONSTRAINT [DF_Office_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Office] ADD  CONSTRAINT [DF_Office_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Office] ADD  CONSTRAINT [DF_Office_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[Office] ADD  CONSTRAINT [DF_Office_DeleteDate]  DEFAULT ('1900-01-01 00:00:00') FOR [DeleteDate]
GO
ALTER TABLE [dbo].[Rule] ADD  CONSTRAINT [DF_Rule_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Rule] ADD  CONSTRAINT [DF_Rule_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Rule] ADD  CONSTRAINT [DF_Rule_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[Rule] ADD  CONSTRAINT [DF_Rule_DeleteDate]  DEFAULT ('1900-01-01 00:00:00') FOR [DeleteDate]
GO
ALTER TABLE [dbo].[Rule_Detail] ADD  CONSTRAINT [DF_Rule_Detail_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Rule_Detail] ADD  CONSTRAINT [DF_Rule_Detail_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Rule_Detail] ADD  CONSTRAINT [DF_Rule_Detail_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[Section] ADD  CONSTRAINT [DF_Section_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Section] ADD  CONSTRAINT [DF_Section_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Section] ADD  CONSTRAINT [DF_Section_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[Section] ADD  CONSTRAINT [DF_Section_DeleteDate]  DEFAULT ('1900-01-01 00:00:00') FOR [DeleteDate]
GO
ALTER TABLE [dbo].[Section_Detail] ADD  CONSTRAINT [DF_Section_Section_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Section_Detail] ADD  CONSTRAINT [DF_Section_Section_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[Section_Detail] ADD  CONSTRAINT [DF_Section_Section_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[Speech] ADD  CONSTRAINT [DF_Speech_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Speech] ADD  CONSTRAINT [DF_Speech_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Speech] ADD  CONSTRAINT [DF_Speech_DeleteDate]  DEFAULT ('1900-01-01 00:00:00') FOR [DeleteDate]
GO
ALTER TABLE [dbo].[Speech] ADD  CONSTRAINT [DF_Speech_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[Speech_Detalle] ADD  CONSTRAINT [DF_Speech_Detalle_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[Speech_Detalle] ADD  CONSTRAINT [DF_Speech_Detalle_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [dbo].[Speech_Detalle] ADD  CONSTRAINT [DF_Speech_Detalle_DeleteDate]  DEFAULT ('1900-01-01 00:00:00') FOR [DeleteDate]
GO
ALTER TABLE [dbo].[Speech_Detalle] ADD  CONSTRAINT [DF_Speech_Detalle_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[SubOffice] ADD  CONSTRAINT [DF_SubOffice_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[SubOffice] ADD  CONSTRAINT [DF_SubOffice_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[SubOffice] ADD  CONSTRAINT [DF_SubOffice_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[SubOffice] ADD  CONSTRAINT [DF_SubOffice_DeleteDate]  DEFAULT ('1900-01-01 00:00:00') FOR [DeleteDate]
GO
ALTER TABLE [dbo].[whiteList] ADD  CONSTRAINT [DF_whiteList_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[whiteList] ADD  CONSTRAINT [DF_whiteList_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[whiteList] ADD  CONSTRAINT [DF_whiteList_Update_Date]  DEFAULT ('1900-01-01 00:00:00') FOR [Update_Date]
GO
ALTER TABLE [dbo].[whiteList] ADD  CONSTRAINT [DF_whiteList_Delete_Date]  DEFAULT ('1900-01-01 00:00:00') FOR [Delete_Date]
GO
ALTER TABLE [dbo].[whiteList_Detail] ADD  CONSTRAINT [DF_whiteList_Detail_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[whiteList_Detail] ADD  CONSTRAINT [DF_whiteList_Detail_Create_Date]  DEFAULT (getdate()) FOR [Create_Date]
GO
ALTER TABLE [dbo].[whiteList_Detail] ADD  CONSTRAINT [DF_whiteList_Detail_Update_Date]  DEFAULT ('1900-01-01 00:00:00') FOR [Update_Date]
GO
ALTER TABLE [dbo].[whiteList_Detail] ADD  CONSTRAINT [DF_whiteList_Detail_Delete_Date]  DEFAULT ('1900-01-01 00:00:00') FOR [Delete_Date]
GO
ALTER TABLE [dbo].[Word] ADD  CONSTRAINT [DF_Word_PK_Enterprise]  DEFAULT ((0)) FOR [PK_Enterprise]
GO
ALTER TABLE [dbo].[WordRule] ADD  CONSTRAINT [DF_WordRule_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[WordRule] ADD  CONSTRAINT [DF_WordRule_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[WordRule] ADD  CONSTRAINT [DF_WordRule_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[WordRule] ADD  CONSTRAINT [DF_WordRule_DeleteDate]  DEFAULT ('1900-01-01 00:00:00') FOR [DeleteDate]
GO
ALTER TABLE [dbo].[WordRule_Detail] ADD  CONSTRAINT [DF_WordRule_Detail_estado]  DEFAULT ((1)) FOR [estado]
GO
ALTER TABLE [dbo].[WordRule_Detail] ADD  CONSTRAINT [DF_WordRule_Detail_CreateDate]  DEFAULT (getdate()) FOR [CreateDate]
GO
ALTER TABLE [dbo].[WordRule_Detail] ADD  CONSTRAINT [DF_WordRule_Detail_UpdateDate]  DEFAULT ('1900-01-01 00:00:00') FOR [UpdateDate]
GO
ALTER TABLE [dbo].[WordRule_Detail]  WITH CHECK ADD  CONSTRAINT [FK_WordRule_Detail_Audio] FOREIGN KEY([PK_audio])
REFERENCES [dbo].[Audio] ([PK_audio])
GO
ALTER TABLE [dbo].[WordRule_Detail] CHECK CONSTRAINT [FK_WordRule_Detail_Audio]
GO
ALTER TABLE [dbo].[WordRule_Detail]  WITH CHECK ADD  CONSTRAINT [FK_WordRule_Detail_WordRule_Detail] FOREIGN KEY([pkWordRule_Detail])
REFERENCES [dbo].[WordRule_Detail] ([pkWordRule_Detail])
GO
ALTER TABLE [dbo].[WordRule_Detail] CHECK CONSTRAINT [FK_WordRule_Detail_WordRule_Detail]
GO
/****** Object:  StoredProcedure [dbo].[busqueda_audios_filtros]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROC [dbo].[busqueda_audios_filtros] 
@pk_business int,
@pk_boss int,
@pk_agent int
AS 
Begin
	select distinct top 500 au.PK_audio,au.seconds,
	au.dateCreated,ag.PK_Agent,bs.PK_Business, ag.FK_Boss, 
	ag.firstNAme +' '+ ag.lastName as 'nameAB', au.dateCreated as 'date',
	bs.name as 'nameBusiness', [state] =(
	case			 
	--when (au.stateBlackList = 4 and au.stateEffectiveness = 5) then 'Procesado'
	when (au.stateBlackList = 5 and au.stateEffectiveness = 5) then 'Procesado'
	when (LEN(au.transcription)>0) then 'Transcrito' 
	when (au.stateBlackList = 0 AND au.stateEffectiveness = 0) then 'Ingresado' 
	end
	),
	--'http://' + n.wanIp + ':' + CAST(n.wwwWanPort AS Nvarchar(10)) + '/' + SUBSTRING(REPLACE(REPLACE(au.dirName, n.storageDirectory, n.streamPath), '\', '/'), 9, LEN(REPLACE(REPLACE(au.dirName, n.storageDirectory, n.streamPath), '\', '/' ))) AS PathMinThumbnails ,
	'-' AS PathMinThumbnails,
	au.fileName,cast(round(au.filesize/1000,3) as varchar(20)) + ' MB'  as filesize
	from  audio  au inner join Agent ag
	on au.FK_Agent=ag.PK_Agent inner join Business bs
	on ag.PK_Business= bs.PK_Business inner join
	Audio a on a.FK_Business= bs.PK_Business
	/*INNER JOIN
	sysNodes.dbo.node AS n ON au.FK_Node = n.PK_Node*/
	where 
	(ag.PK_Business = @pk_business or @pk_business = 0)
	and (ag.FK_Boss = @pk_boss or @pk_boss = 0) 
	and (ag.PK_Agent = @pk_agent or @pk_agent = 0)
	and au.seconds > 0
	order by pk_audio desc
End
GO
/****** Object:  StoredProcedure [dbo].[OBTENER_PALABRAS_POR_SPEECH]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE procedure [dbo].[OBTENER_PALABRAS_POR_SPEECH]
@PK_Speech int
as
begin
	Select t3.PK_WordRule,
	t2.PK_Rule,
	t3.word,
	case when t1.weight>0 then t1.weight/100 else 0 end as NU_WeightSection,
	case when t2.weight>0 then t2.weight/100 else 0 end as NU_WeightRule
	from Speech t0
	inner join Section t1
	on t1.PK_Speech=t0.PK_Speech
	inner join [Rule] t2
	on t2.PK_Section=t1.PK_Section
	inner join WordRule t3
	on t3.PK_Rule=t2.PK_Rule
	where t0.PK_Speech=@PK_Speech;
end;
GO
/****** Object:  StoredProcedure [dbo].[Rsp_Audio_Detalle]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCEDURE [dbo].[Rsp_Audio_Detalle]
@PK_Audio char(8)
 AS BEGIN
		  select au.fileName,[text],startSecond,endSecond,
		  --round(cast(duration as decimal),2) as duration 
		  duration
		  from [dbo].[AudioTranscription] aut
		  inner join Audio au on au.PK_audio = aut.PK_Audio
		  where aut.PK_Audio=@pk_Audio
		  order by startSecond asc 
 END
GO
/****** Object:  StoredProcedure [dbo].[Rsp_Login]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Rsp_Login] 
@usuario  Varchar(40),
@password Varchar(50)
as
Begin
	SELECT cast([pk_usuario] as varchar(20)) as 'pk_usuario' ,
	usuario,
	[Password] AS [Password],
	Name_user,
	email,
	ISNULL(pk_enterprise,0) AS pk_enterprise
	FROM [LOGIN]
	WHERE usuario=@usuario 
	and [Password]=@password
End
GO
/****** Object:  StoredProcedure [dbo].[SP_BUSINESS_COMBO]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_BUSINESS_COMBO]
@PK_SubOffice INT
AS
BEGIN
	SELECT T0.PK_Business,
	T0.name
	FROM Business T0
	WHERE T0.estado=1
	AND T0.PK_SubOffice=@PK_SubOffice;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_ENTERPRISE_COMBO]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ENTERPRISE_COMBO]
AS
BEGIN
	SELECT PK_Enterprise,
	Name
	FROM Enterprise
	WHERE estado=1;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_ENTERPRISE_ELIMINAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_ENTERPRISE_ELIMINAR]
@PK_Enterprise INT
AS
BEGIN
	UPDATE Enterprise
	SET estado=0
	WHERE PK_Enterprise=@PK_Enterprise;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_ENTERPRISE_LISTAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[SP_ENTERPRISE_LISTAR]
@Name varchar(50),
@estado INT
AS
BEGIN
	SELECT PK_Enterprise,
	Name,
	isnull(estado,0) as estado,
	case when estado = 1 then 'ACTIVO' else 'INACTIVO' end as Tx_Estado
	FROM Enterprise
	where estado=@estado
	and (@Name is null or Name like '%' + @Name + '%');
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_ENTERPRISE_REGISTRAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_ENTERPRISE_REGISTRAR]
@PK_Enterprise INT,
@Name VARCHAR(50),
@estado INT
AS
BEGIN
	IF @PK_Enterprise=0
	BEGIN
		INSERT INTO Enterprise
		(Name,estado)
		VALUES
		(@Name,@estado);
	END ELSE BEGIN
		UPDATE Enterprise
		SET Name=@Name,
		estado=@estado
		WHERE PK_Enterprise=@PK_Enterprise;
	END;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_INS_ENTERPRISEFTP]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCEDURE [dbo].[SP_INS_ENTERPRISEFTP]
@PK_Enterprise int
,@Server varchar(20)
,@Port varchar(10)
,@Folder varchar(50)
,@Username varchar(50)
,@Password varchar(50)
AS
BEGIN
	INSERT INTO [dbo].[EnterpriseFTP]
           ([PK_Enterprise]
           ,[Server]
           ,[Port]
           ,[Folder]
           ,[Username]
           ,[Password])
     VALUES
           (@PK_Enterprise
           ,@Server
           ,@Port
           ,@Folder
           ,@Username
           ,@Password);
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ListaAlertas]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[sp_ListaAlertas]
as
select bla.pk as Id,
'word' = 'Negocio: ' + bu.name + '		    Agente: ' + isnull(ag.firstNAme,'') + ' ' + isnull(ag.lastName,''),  
'tiempo' = DATEDIFF(HOUR,dateInclude,getdate())
from ResultsBlackList result
inner join blacklist bla on result.Composition = bla.pk
inner join Audio au on au.pk_audio = result.pk_audio 
inner join Agent ag on ag.pk_agent = au.fk_agent
inner join Business bu on bu.PK_Business = au.FK_Business
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_AUDIO_DETALLE]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_LISTAR_AUDIO_DETALLE]
@PK_audio INT
AS
BEGIN
	select T0.PK_Speech,
		T0.PK_audio,
		T0.PK_Section,
		T0.PK_Rule,
		T0.PK_WordRule,
		T0.pkWordRule_Detail,
		T0.TX_Speech,
		T0.TX_Transcripcion,
		T0.TX_Section,
		ISNULL(T0.NU_SectionWeight,0) AS NU_SectionWeight,
		T0.TX_Rule,
		ISNULL(T0.NU_RuleWeight,0) AS NU_RuleWeight,
		T0.TX_Word,
		T0.TX_WordAudio,
		ISNULL(T0.NU_WordWeight,0) AS NU_WordWeight
	from (
		SELECT T0.PK_Speech,
		t5.PK_audio,
		T1.PK_Section,
		T2.PK_Rule,
		T3.PK_WordRule,
		t4.pkWordRule_Detail,
		T0.[name] AS TX_Speech,
		t5.transcription AS TX_Transcripcion,
		t1.[name] AS TX_Section,
		case when T1.[weight]>0 then T1.[weight]/100 else 0 end AS NU_SectionWeight,
		t2.[name] AS TX_Rule,
		case when t2.weight>0 then t2.weight/100 else 0 end AS NU_RuleWeight,
		T3.word AS TX_Word,
		--T5.transcription AS TX_Transcripcion,
		T4.word AS TX_WordAudio,
		T4.weight AS NU_WordWeight,
		ROW_NUMBER() OVER(PARTITION BY t5.PK_audio, T2.PK_Rule ORDER BY T4.word desc) AS ROW_ORDEN
		FROM Speech T0
		INNER JOIN Section T1
		ON T1.PK_Speech=T0.PK_Speech
		INNER JOIN Audio T5
		ON T5.FK_Speech=T0.PK_Speech
		INNER JOIN [Rule] T2
		ON T2.PK_Section=T1.PK_Section
		INNER JOIN WordRule T3
		ON T3.PK_Rule=T2.PK_Rule
		LEFT JOIN WordRule_Detail T4
		ON T4.PK_WordRule = T3.PK_WordRule
		AND T4.PK_Audio=t5.pk_audio
		where t5.PK_audio=@PK_audio
	) T0 where T0.ROW_ORDEN=1;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_LISTAR_AUDIO_POR_SPEECH]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_LISTAR_AUDIO_POR_SPEECH]
@PK_Business INT,
@PK_Speech INT
AS
BEGIN
	select T0.PK_Speech,
	T0.PK_audio,
	T0.TX_Business,
	T0.TX_Speech,
	T0.TX_Transcripcion,
	SUM(ISNULL(T0.NU_WordWeight,0)) as NU_WordWeight
	from (
		SELECT TT.PK_Business,
		T0.PK_Speech,
		t5.PK_audio,
		T1.PK_Section,
		T2.PK_Rule,
		T3.PK_WordRule,
		t4.pkWordRule_Detail,
		TT.[name] AS TX_Business,
		T0.[name] AS TX_Speech,
		t5.transcription AS TX_Transcripcion,
		t1.[name] AS TX_Section,
		case when T1.[weight]>0 then T1.[weight]/100 else 0 end AS NU_SectionWeight,
		t2.[name] AS TX_Rule,
		case when t2.weight>0 then t2.weight/100 else 0 end AS NU_RuleWeight,
		T3.word AS TX_Word,
		--T5.transcription AS TX_Transcripcion,
		T4.word AS TX_WordAudio,
		T4.weight AS NU_WordWeight,
		ROW_NUMBER() OVER(PARTITION BY t5.PK_audio, T2.PK_Rule ORDER BY T4.word desc) AS ROW_ORDEN
		FROM Business TT
		INNER JOIN Speech T0
		ON T0.FK_business=TT.PK_Business
		INNER JOIN Section T1
		ON T1.PK_Speech=T0.PK_Speech
		INNER JOIN Audio T5
		ON T5.FK_Speech=T0.PK_Speech
		INNER JOIN [Rule] T2
		ON T2.PK_Section=T1.PK_Section
		INNER JOIN WordRule T3
		ON T3.PK_Rule=T2.PK_Rule
		LEFT JOIN WordRule_Detail T4
		ON T4.PK_WordRule = T3.PK_WordRule
		AND T4.PK_Audio=t5.pk_audio
		where TT.PK_Business=@PK_Business
		AND (@PK_Speech=0 OR T0.PK_Speech=@PK_Speech)
	) T0 where T0.ROW_ORDEN=1
	group by T0.PK_Speech,
	T0.PK_audio,
	T0.TX_Business,
	T0.TX_Speech,
	T0.TX_Transcripcion;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ListarNotificaciones]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[sp_ListarNotificaciones]
as
select Id,Tabla,
'tiempo' = DATEDIFF(HOUR,FechaCreacion,getdate()) 
from Notificaciones

GO
/****** Object:  StoredProcedure [dbo].[SP_LOGIN]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_LOGIN] 
@LOG_USU_VC Varchar(40),
@PASS_USU_VC Varchar(50)
AS
BEGIN
	SELECT ID_USU_IN,
	NOMBRE_VC,
	LOG_USU_VC,
	DES_EMA_VC,
	ISNULL(ID_EMP_IN,0) AS ID_EMP_IN
	FROM TBL_USUARIO
	WHERE LOG_USU_VC=@LOG_USU_VC
	AND PASS_USU_VC=@PASS_USU_VC;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_LST_ENTERPRISEFTP]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_LST_ENTERPRISEFTP]
@PK_Enterprise int
AS
BEGIN
	SELECT T0.PK_ftp,
	T0.PK_Enterprise,
	T1.Name,
	T0.Server,
	T0.Port,
	T0.Folder,
	T0.Username,
	T0.Password
	FROM EnterpriseFTP T0
	INNER JOIN Enterprise T1
	ON T1.PK_Enterprise=T0.PK_Enterprise
	WHERE @PK_Enterprise=0 or T0.PK_Enterprise=@PK_Enterprise;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_NEGOCIO_COMBO]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_NEGOCIO_COMBO]
@PK_SubOffice INT
AS
BEGIN
	Select t0.PK_Business,
	t0.name
	from Business t0
	where t0.PK_SubOffice=@PK_SubOffice
	and t0.estado=1;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_NEGOCIO_ELIMINAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_NEGOCIO_ELIMINAR]
@PK_Business INT
AS
BEGIN
	UPDATE Business
	SET estado=0,
	DeleteDate=GETDATE()
	WHERE PK_Business=@PK_Business;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_NEGOCIO_LISTAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_NEGOCIO_LISTAR]
@PK_Enterprise INT,
@PK_SubOffice INT,
@PK_Office INT,
@Name varchar(300),
@estado INT
AS
BEGIN
	SELECT t0.PK_Business,
	t1.PK_SubOffice,
	t2.PK_Office,
	t2.PK_Enterprise,
	t2.nameOffice,
	t1.nameSubOffice,
	t0.name,
	t0.estado,
	case when t0.estado = 1 then 'ACTIVO' else 'INACTIVO' end as Tx_Estado
	FROM business t0
	inner join SubOffice t1
	on t1.PK_SubOffice=t0.PK_SubOffice
	inner join Office t2
	on t2.PK_Office=t1.PK_Office
	where t2.PK_Enterprise=@PK_Enterprise
	AND t0.estado=@estado
	AND (@PK_Office=0 or t2.PK_Office=@PK_Office)
	AND (@PK_SubOffice=0 or t1.PK_SubOffice=@PK_SubOffice)
	AND (@Name is null or t0.name like '%' + @Name + '%');
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_NEGOCIO_REGISTRAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_NEGOCIO_REGISTRAR]
@PK_Business INT, 
@PK_SubOffice INT, 
@Name VARCHAR(500),
@Estado int
AS
BEGIN
	IF @PK_Business=0 BEGIN
		INSERT INTO Business
		(PK_SubOffice, name, estado, active, CreateDate)
		VALUES
		(@PK_SubOffice, @Name, @Estado, 1, GETDATE());
	END ELSE BEGIN
		UPDATE Business
		SET name=@Name,
		estado=@Estado,
		UpdateDate=GETDATE()
		WHERE PK_Business=@PK_Business;
	END;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_OBTENER_FTP_ID]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_OBTENER_FTP_ID]
@PK_ftp int
AS
BEGIN
	SELECT T0.PK_ftp,
	T0.Server,
	T0.Port,
	T0.Folder,
	T0.Username,
	T0.Password
	FROM EnterpriseFTP T0
	WHERE T0.PK_ftp=@PK_ftp;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_OFICINA_COMBO]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_OFICINA_COMBO]
@PK_Enterprise INT
AS
BEGIN
	SELECT PK_Office,
	nameOffice
	FROM Office
	WHERE estado=1
	and PK_Enterprise=@PK_Enterprise;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_OFICINA_ELIMINAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_OFICINA_ELIMINAR]
@PK_Office INT
AS
BEGIN
	UPDATE Office
	SET estado=0
	WHERE PK_Office=@PK_Office;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_OFICINA_LISTAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_OFICINA_LISTAR]
@PK_Enterprise INT,
@NameOffice varchar(500),
@estado INT
AS
BEGIN
	SELECT PK_Office,
	PK_Enterprise,
	nameOffice,
	estado,
	case when estado = 1 then 'ACTIVO' else 'INACTIVO' end as Tx_Estado
	FROM Office
	WHERE PK_Enterprise=@PK_Enterprise
	AND estado=@estado
	AND (@NameOffice is null or nameOffice like '%' + @NameOffice + '%');
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_OFICINA_REGISTRAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_OFICINA_REGISTRAR]
@PK_Office int,
@PK_Enterprise INT,
@NameOffice varchar(500),
@estado INT
AS
BEGIN
	IF @PK_Office=0
	BEGIN
		INSERT INTO Office
		(PK_Enterprise,nameOffice,estado,CreateDate)
		VALUES
		(@PK_Enterprise,@NameOffice,@estado,getdate());
	END ELSE BEGIN
		UPDATE Office
		SET nameOffice=@NameOffice,
		estado=@estado,
		UpdateDate=getdate()
		WHERE PK_Office=@PK_Office;
	END;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_RULE_ELIMINAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_RULE_ELIMINAR]
@PK_Rule int
AS
BEGIN
	Update [Rule]
	set estado = 0,
	DeleteDate = getdate()
	where PK_Rule=@PK_Rule; 
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_RULE_LISTAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_RULE_LISTAR]
@PK_Enterprise INT,
@PK_Office INT,
@PK_SubOffice INT,
@PK_Business INT,
@PK_Speech INT,
@PK_Section INT,
@Name VARCHAR(300),
@estado INT
AS
BEGIN
	SELECT T0.PK_Rule,
	T1.PK_Section,
	T2.PK_Speech,
	T2.name AS NameSpeech
	FROM [Rule] T0
	INNER JOIN Section T1
	ON T1.PK_Section=T0.PK_Section
	INNER JOIN Speech T2
	ON T2.PK_Speech=T1.PK_Speech
	INNER JOIN Business T3
	ON T3.PK_Business=T2.FK_business
	INNER JOIN SubOffice T4
	ON T4.PK_SubOffice=T3.PK_SubOffice
	INNER JOIN Office T5
	ON T5.PK_Office=T4.PK_Office
	WHERE T5.PK_Enterprise=@PK_Enterprise
	AND T5.PK_Office=@PK_Office
	AND T4.PK_SubOffice=@PK_SubOffice
	AND T3.PK_Business=@PK_Business
	AND (@PK_Speech=0 OR T2.PK_Speech=@PK_Speech)
	AND (@PK_Section=0 OR T1.PK_Section=@PK_Section)
	AND (@Name is null or T0.name like '%' + @Name + '%')
	AND t0.estado=@estado;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_RULE_REGISTRAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_RULE_REGISTRAR]
@PK_Rule int, 
@PK_Section int, 
@name varchar(300), 
@weight numeric(5,2), 
@estado int
AS
BEGIN
	IF @PK_Rule=0 BEGIN
		Insert into [Rule]
		(PK_Section, name, weight, estado,CreateDate)
		values
		(@PK_Section, @name, @weight, @estado,getdate());
	END ELSE BEGIN
		Update [Rule]
		set PK_Section = @PK_Section, 
		name = @name, 
		weight = @weight, 
		estado = @estado,
		UpdateDate = getdate()
		where PK_Rule=@PK_Rule;
	END;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SECTION_COMBO]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_SECTION_COMBO]
@PK_Speech INT
AS
BEGIN
	SELECT T0.PK_Speech,
	T0.name
	FROM Section T0
	WHERE T0.estado=1
	AND T0.PK_Speech=@PK_Speech;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SECTION_ELIMINAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_SECTION_ELIMINAR]
@PK_Section INT
AS
BEGIN
	UPDATE Section
	SET estado=0,
	DeleteDate=GETDATE()
	WHERE PK_Section=@PK_Section;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SECTION_LISTAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SECTION_LISTAR]
@PK_Enterprise INT,
@PK_Office INT,
@PK_SubOffice INT,
@PK_Business INT,
@PK_Speech INT,
@Name VARCHAR(300),
@estado INT
AS
BEGIN
	SELECT T0.PK_Section,
	T1.PK_Speech,
	T2.PK_Business,
	T3.PK_SubOffice,
	T4.PK_Office,
	T4.PK_Enterprise,
	T2.name AS NameSpeech,
	T0.name AS NameSection,
	t0.descripcion,
	isnull(t0.weight,0) as weight,
	isnull(t0.TMO,0) as TMO,
	t0.estado,
	case when t0.estado = 1 then 'ACTIVO' else 'INACTIVO' end as Tx_Estado
	FROM Section T0
	INNER JOIN Speech T1
	ON T1.PK_Speech=T0.PK_Speech
	INNER JOIN Business T2
	ON T2.PK_Business=T1.FK_business
	INNER JOIN SubOffice T3
	ON T3.PK_SubOffice=T2.PK_SubOffice
	INNER JOIN Office T4
	ON T4.PK_Office=T3.PK_Office
	WHERE T4.PK_Enterprise=@PK_Enterprise
	AND (@PK_Office=0 or T4.PK_Office=@PK_Office)
	AND (@PK_SubOffice=0 or T3.PK_SubOffice=@PK_SubOffice)
	AND (@PK_Business=0 or T2.PK_Business=@PK_Business)
	AND (@PK_Speech=0 OR T1.PK_Speech=@PK_Speech)
	AND (@Name is null or T0.name like '%' + @Name + '%')
	AND t0.estado=@estado;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SECTION_REGISTRAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_SECTION_REGISTRAR]
@PK_Section INT,
@PK_Speech INT, 
@name VARCHAR(300), 
@descripcion VARCHAR(MAX), 
@weight NUMERIC(5,2), 
@TMO NUMERIC(5,2), 
@estado INT
AS
BEGIN
	IF @PK_Section=0 BEGIN
		INSERT INTO Section
		(PK_Speech, name, descripcion, weight, TMO, estado, CreateDate)
		VALUES
		(@PK_Speech, @name, @descripcion, @weight, @TMO, @estado, GETDATE());
	END ELSE BEGIN
		UPDATE Section
		SET PK_Speech=@PK_Speech, 
		name=@name, 
		descripcion=@descripcion, 
		weight=@weight, 
		TMO=@TMO, 
		estado=@estado,
		UpdateDate=GETDATE()
		WHERE PK_Section=@PK_Section;
	END;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SPEECH_COMBO]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_SPEECH_COMBO]
@FK_business INT
AS
BEGIN
	SELECT T0.PK_Speech,
	T0.name
	FROM Speech T0
	WHERE T0.estado=1
	AND T0.FK_business=@FK_business;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SPEECH_ELIMINAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_SPEECH_ELIMINAR]
@PK_Speech int
AS
BEGIN
	UPDATE Speech
	SET estado=0,
	DeleteDate=GETDATE()
	WHERE PK_Speech=@PK_Speech;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SPEECH_LISTAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SPEECH_LISTAR]
@PK_Enterprise INT,
@PK_Office INT,
@PK_SubOffice INT,
@PK_Business INT,
@Name VARCHAR(300),
@estado INT
AS
BEGIN
	select T0.PK_Speech,
	T1.PK_Business,
	T2.PK_SubOffice,
	T3.PK_Office,
	T3.PK_Enterprise,
	t3.nameOffice,
	t2.nameSubOffice,	
	t1.name as nameBusiness,
	t0.name as nameSpeech,
	t0.description,
	t0.estado,
	case when t0.estado = 1 then 'ACTIVO' else 'INACTIVO' end as Tx_Estado
	from Speech T0
	INNER JOIN Business T1
	ON T1.PK_Business=T0.FK_business
	INNER JOIN SubOffice T2
	ON T2.PK_SubOffice=T1.PK_SubOffice
	INNER JOIN Office T3
	ON T3.PK_Office=T2.PK_Office
	WHERE T3.PK_Enterprise=@PK_Enterprise
	AND (@PK_Office=0 OR T2.PK_Office=@PK_Office)
	AND (@PK_SubOffice=0 OR T2.PK_SubOffice=@PK_SubOffice)
	AND (@PK_Business=0 OR T1.PK_Business=@PK_Business)
	AND (@Name is null or T1.name like '%' + @Name + '%')
	AND T0.estado=@estado;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SPEECH_REGISTRAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SPEECH_REGISTRAR]
@PK_Speech int, 
@FK_business int, 
@name varchar(350), 
@description varchar(max), 
@estado int
AS
BEGIN
	IF @PK_Speech=0 BEGIN
		Insert into Speech
		(FK_business, name, description, estado, CreatedDate)
		values
		(@FK_business, @name, @description, @estado, getdate());
	END ELSE BEGIN
		update Speech
		set FK_business=@FK_business,
		name=@name,
		description=@description,
		estado=@estado,
		UpdateDate=getdate()
		where PK_Speech=@PK_Speech;
	END;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SUB_OFICINA_COMBO]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SUB_OFICINA_COMBO]
@PK_Office INT
AS
BEGIN
	SELECT PK_SubOffice,
	nameSubOffice
	FROM SubOffice
	WHERE estado=1
	and PK_Office=@PK_Office;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SUB_OFICINA_ELIMINAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_SUB_OFICINA_ELIMINAR]
@PK_SubOffice INT
AS
BEGIN
	UPDATE SubOffice
	SET estado=0
	WHERE PK_SubOffice=@PK_SubOffice;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SUB_OFICINA_LISTAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SP_SUB_OFICINA_LISTAR]
@PK_Enterprise INT,
@PK_Office INT,
@NameSubOffice varchar(300),
@estado INT
AS
BEGIN
	SELECT t1.PK_Enterprise,
	t1.PK_Office,
	t0.PK_SubOffice,
	t1.nameOffice,
	t0.nameSubOffice,
	t0.estado,
	case when t0.estado = 1 then 'ACTIVO' else 'INACTIVO' end as Tx_Estado
	FROM SubOffice t0
	inner join Office t1
	on t1.PK_Office=t0.PK_Office
	WHERE t1.PK_Enterprise=@PK_Enterprise
	AND t0.estado=@estado
	AND (@PK_Office=0 or t0.PK_Office=@PK_Office)
	AND (@NameSubOffice is null or t0.nameSubOffice like '%' + @NameSubOffice + '%');
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_SUB_OFICINA_REGISTRAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_SUB_OFICINA_REGISTRAR]
@PK_SubOffice INT,
@PK_Office int,
@NameSubOffice varchar(500),
@estado INT
AS
BEGIN
	IF @PK_SubOffice=0
	BEGIN
		INSERT INTO SubOffice
		(PK_Office,nameSubOffice,estado,CreateDate)
		VALUES
		(@PK_Office, @NameSubOffice,@estado,getdate());
	END ELSE BEGIN
		UPDATE SubOffice
		SET nameSubOffice=@NameSubOffice,
		estado=@estado,
		UpdateDate=getdate()
		WHERE PK_Office=@PK_Office;
	END;
END;
GO
/****** Object:  StoredProcedure [dbo].[SP_WORDRULE_DETAIL_REGISTRAR]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[SP_WORDRULE_DETAIL_REGISTRAR]
@PK_audio int
,@PK_WordRule int
,@PK_Rule int
,@word varchar(100)
,@sequence int
,@time_word numeric(6,4)
,@weight numeric(5,2)
AS
BEGIN
	INSERT INTO dbo.WordRule_Detail
           (PK_audio
		   ,PK_WordRule
           ,PK_Rule
           ,word
           ,sequence
           ,time_word
           ,weight
           ,estado
           ,CreateDate)
     VALUES
           (@PK_audio
		   ,@PK_WordRule
           ,@PK_Rule
           ,@word
           ,@sequence
           ,@time_word
           ,@weight
           ,1
           ,GETDATE())
END;
GO
/****** Object:  StoredProcedure [dbo].[spAgregarAudio]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCedure [dbo].[spAgregarAudio]
(
@FkBusiness int,
@Fk_Speech int,
@Fk_Agent int,
@Number varchar(20),
@texto varchar(max),
@NombreArchivo varchar(100),
@FechaCreacionAudio datetime,
@WeightAudio varchar(100),
@RutaCompleta varchar(max),
@IdPkAudio int output
)
as declare @idCall int
--declare @Fk_Speech int,@Fk_Agent int,@Fk_Call int 
--declare @RutaCompleta varchar(max)

--set @RutaCompleta = 'C:\Apps\CallCloud\Content\audios\'
--set @FkBusiness = 13
insert into Call values(@FKBusiness,getdate(),null,@Number,@Number,1)
set @idCall = SCOPE_IDENTITY();

--set @Fk_Speech  = (select top 1 pk_speech from Speech where fk_business = @FkBusiness and estado = 1)
--set @Fk_Agent = (select top 1 pk_agent from Agent where DNI = @Dni)
--set @Fk_Call = (select top 1 pk_Call from Call where number_in = @Number)

--set @WeightAudio = cast(@WeightAudio as real)

insert into Audio 
(seconds
,status
,dateCreated
,dateInclude
,FK_node
,filesize
,transcription
,AudioFreq
,taskAudiothumbnail
,taskAudioMp3
,taskAudioTranscriptor
,fileName
,dirName
,FK_Speech
,FK_Agent
,FK_Call
,fileNamewav
,dirNamewav
,performance
,fileNameMp3Ecualized
,dirNameMp3Ecualized
,fileNameWavEcualized
,dirNameWavEcualized
,state
,stateWhiteList
,stateBlackList
,stateEffectiveness
,StateWhiteError
,StateBlackListError
,FK_Business
,stateAlertEmail)
values(
0,--<seconds, int,>
0,--<status, int,>
@FechaCreacionAudio,--<dateCreated, datetime,>
getdate(),--<dateInclude, datetime,>
1,--<FK_node, int,>
round(cast(@WeightAudio as real)/1000,2),--<filesize, real,>
@texto,--<transcription, nvarchar(max),>
null,--<AudioFreq, int,>
null,--<taskAudiothumbnail, int,>
null,--<taskAudioMp3, int,>
null,--<taskAudioTranscriptor, int,>
@NombreArchivo,--<fileName, nvarchar(max),>
@RutaCompleta,--<dirName, nvarchar(max),>
@Fk_Speech,--<FK_Speech, int,>
@Fk_Agent,--<FK_Agent, int,>
@idCall,--<FK_Call, int,>
null,--<fileNamewav, nvarchar(max),>
null,--<dirNamewav, nvarchar(max),>
null,--<performance, int,>
null,--<fileNameMp3Ecualized, nvarchar(max),>
null,--<dirNameMp3Ecualized, nvarchar(max),>
null,--<fileNameWavEcualized, nvarchar(max),>
null,--<dirNameWavEcualized, nvarchar(max),>
0,--<state, int,>
0,--<stateWhiteList, int,>
0,--<stateBlackList, int,>
0,--<stateEffectiveness, int,>
0,--<StateWhiteError, int,>
0,--<StateBlackListError, int,>
@FkBusiness,--<FK_Business, int,>
0)--<stateAlertEmail, int,>

set @IdPkAudio = SCOPE_IDENTITY() 

--alter table Audio alter column filesize real


GO
/****** Object:  StoredProcedure [dbo].[spAgregarAudioTranscription]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[spAgregarAudioTranscription]
(
@starSecond real,
@endSecond real,
--@duracion real,
@text varchar(100),
@pk_audio int
)
as

declare @duracion as real 

--set @starSecond =  substring(@starSecond,2,len(@starSecond) - 3)
--set @endSecond =  substring(@endSecond,2,len(@endSecond) - 3)

--select @starSecond 
--set @starSecond = cast(@starSecond as real)
--set @endSecond = cast(@endSecond as real)

--set @duracion =  cast(@endSecond as real) - cast(@starSecond as real)
set @duracion =  @endSecond - @starSecond

insert into AudioTranscription values(@starSecond,@endSecond,@duracion,@text,@pk_audio,0)

declare @maxSecondAudio int

set @maxSecondAudio = (select cast(max(endsecond) as int) from Audiotranscription where pk_audio = @pk_audio)

update Audio 
set seconds = @maxSecondAudio
where pk_audio = @pk_audio
/*
declare @starSecond varchar(100)
set @starSecond = '3.100s'
select substring(@starSecond,1,len(rtrim(@starSecond)) - 1),len(@starSecond)
*/

GO
/****** Object:  StoredProcedure [dbo].[uspAgentInsUp]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[uspAgentInsUp]
(
	@pPK_Agent		Int,
	@pFirstName		VarChar(1000),
	@pLastName  	VarChar(1000),
	@pPK_Bussines	Int,
	@pDNI			VarChar(8),
	@pCodInt		VarChar(20),
	@Fk_Boss int,
	@Flag_Fk_Boss bit,
	@Mail varchar(100) = null,
	@pOutVal			Int OutPut
)
As
Begin
	if (@Flag_Fk_Boss = 1)  -- Cuando es Supervisor
		begin 
 	
			If Exists (Select firstNAme
					   From Agent
					   Where PK_Agent=@pPK_Agent)
					Begin
						Update Agent
							Set firstNAme=@pFirstName, lastName= @pLastName,
								Pk_Business=@pPK_Bussines, DNI=@pDNI,Mail=@Mail,
								CodInt=@pCodInt,Update_Date=GETDATE(),
								FK_Boss = 0							
						Where PK_Agent=@pPK_Agent
						Set @pOutVal=2
					End
			Else
					Begin	
						Insert Into Agent (firstNAme,lastName,PK_Business,DNI,Mail,CodInt,FK_Boss)Values(@pFirstName,@pLastName,@pPK_Bussines,@pDNI,@Mail,@pCodInt,0)
						Set @pOutVal=1
					End
		End
	else
		begin
			If Exists (Select firstNAme
					   From Agent
					   Where PK_Agent=@pPK_Agent)
					Begin
						Update Agent
							Set firstNAme=@pFirstName, lastName= @pLastName,
								Pk_Business=@pPK_Bussines, DNI=@pDNI,Mail = @Mail,FK_Boss=@Fk_Boss,CodInt=@pCodInt,Update_Date=GETDATE()							
						Where PK_Agent=@pPK_Agent
						Set @pOutVal=2
					End
			Else
					Begin	
						Insert Into Agent (firstNAme,lastName,PK_Business,DNI,Mail,CodInt,FK_Boss)Values(@pFirstName,@pLastName,@pPK_Bussines,@pDNI,@Mail,@pCodInt,@Fk_Boss)
						Set @pOutVal=1
			End
		End
End
GO
/****** Object:  StoredProcedure [dbo].[uspAgentLst]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure  [dbo].[uspAgentLst]
(
	@pFirstName		VarChar(1000),
	@pLastName  	VarChar(1000),
	@pPK_Bussines	Int
)
As
Begin
	Select PK_Agent,firstNAme,lastName,B.name,DNI,CodInt
	From Agent	A
	Inner Join Business B On A.PK_Business=B.PK_Business
	Where (firstNAme like '%'+@pFirstName+'%' Or @pFirstName='') And	
		  (lastName like '%'+@pLastName	+'%' Or @pLastName='')	 And
		  (A.PK_Business=@pPK_Bussines or @pPK_Bussines=0)	and A.estado=1	  
End
GO
/****** Object:  StoredProcedure [dbo].[uspAgentLstBossAudio]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure  [dbo].[uspAgentLstBossAudio] 
@pPK_Business int
As
Begin
	Select A.PK_Agent,A.firstNAme +' '+A.lastName as 'firstNAme',A.DNI,A.CodInt,A.FK_Boss,a.PK_Business
	From Agent	A
	Where A.FK_Boss=A.PK_Agent or A.FK_Boss=null or A.FK_Boss='' and A.estado=1	and (A.PK_Business=@pPK_Business
	 or @pPK_Business= 0 or @pPK_Business= null)
End
GO
/****** Object:  StoredProcedure [dbo].[uspAgentLstByAgent]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[uspAgentLstByAgent]
@pPkBoss int
As
Begin 	
	Select PK_Agent,firstNAme + ' '+lastName as 'firstNAme', FK_Boss
	From Agent	A
	where FK_Boss !=0 and A.estado=1 and (FK_Boss=@pPkBoss or @pPkBoss=0 or @pPkBoss=null) 
End
GO
/****** Object:  StoredProcedure [dbo].[uspBlackLis_Lst]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[uspBlackLis_Lst]
@word varchar(max),
@enterprise int

as
	select B.pk,B.word,E.Name from blackList B
	inner join Enterprise E
	on B.Enterprise = E.PK_Enterprise
	where word like '%'+@word+'%' and (Enterprise=@enterprise or @enterprise=0)
	and B.estado = 1 and E.estado=1

GO
/****** Object:  StoredProcedure [dbo].[uspBusiness]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCedure [dbo].[uspBusiness]
@PK_SubOffice int
as
begin
	select PK_Business,name from Business
	where estado=1
	and (@PK_SubOffice=0 or PK_SubOffice=@PK_SubOffice);
end;
GO
/****** Object:  StoredProcedure [dbo].[uspBusinessLst]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[uspBusinessLst]
as
Begin
	select PK_Business,name from Business
	where active=1
End
GO
/****** Object:  StoredProcedure [dbo].[uspEnterprise]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCedure [dbo].[uspEnterprise]
As
Begin 
	Select PK_Enterprise,Name From Enterprise	
End
GO
/****** Object:  StoredProcedure [dbo].[uspOfficeDel]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCedure [dbo].[uspOfficeDel]
(
	@ppPK_Office		Int
)
As
Begin 
	update  Office set estado=0, DeleteDate = getdate()
	Where PK_Office=@ppPK_Office
End
GO
/****** Object:  StoredProcedure [dbo].[uspOfficeInsUp]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[uspOfficeInsUp]
(
	@pPK_Office		Int,
	@pnameOffice		VarChar(1000),	
	@pPK_Enterprise 	Int,
	@pOutVal			Int OutPut
)
As
Begin	
	If Exists (Select nameOffice
			   From Office
			   Where PK_Office=@pPK_Office)
			Begin
				Update Office
					Set nameOffice=@pnameOffice, PK_Enterprise= @pPK_Enterprise,
						UpdateDate=GETDATE()							
				Where PK_Office=@pPK_Office
				Set @pOutVal=2
			End
	Else
			Begin	
				Insert Into Office (nameOffice,PK_Enterprise)Values(@pnameOffice,@pPK_Enterprise)
				Set @pOutVal=1
			End
End
GO
/****** Object:  StoredProcedure [dbo].[uspOfficeLst]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure  [dbo].[uspOfficeLst] 
(
	@pnameOffice  	VarChar(1000),
	@pPK_Enterprise	Int
)
As
Begin
	Select PK_Office,nameOffice,B.Name
	From Office	A
	Inner Join Enterprise B On A.PK_Enterprise=B.Pk_Enterprise
	Where (nameOffice like '%'+@pnameOffice+'%' Or @pnameOffice='' or @pnameOffice=null) And	
		  
		  (A.PK_Enterprise=@pPK_Enterprise or @pPK_Enterprise=0)	and A.estado=1  
End
GO
/****** Object:  StoredProcedure [dbo].[uspRuleById]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCedure [dbo].[uspRuleById] 
(
	@pPK_Rule		Int
)
As
Begin
	Select S.PK_Speech,Sp.name 'SpeechName' ,R.PK_Rule,R.PK_Section,S.name 'SectionName', R.name,R.time_rule,R.weight
	From [Rule] R 
	inner join Section S
	on R.PK_Section=S.PK_Section
	inner join Speech Sp
	on Sp.PK_Speech=S.PK_Speech
	Where R.PK_Rule=@pPK_Rule and R.estado=1 and S.estado=1
End
GO
/****** Object:  StoredProcedure [dbo].[uspRuleLst]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCedure [dbo].[uspRuleLst]
(
	@pPK_Section	Int,
	@pName			VarChar(300)	
)
As
Begin 
	Select PK_Rule,R.name,S.name 'SeccionName',time_rule,R.[weight]
	From [Rule] R
	Inner Join Section S On R.PK_Section=S.PK_Section
	Where (R.PK_Section=@pPK_Section Or @pPK_Section=0) And
		  R.name like '%'+@pName+'%' and
		  (R.PK_Section=S.PK_Section) and R.estado=1
End
GO
/****** Object:  StoredProcedure [dbo].[uspSectionById]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCedure [dbo].[uspSectionById]
(
	@pPK_Section		Int
)
As
Begin 
	Select Sp.PK_Speech, Sp.name 'SpeechName', S.PK_Section,S.name, S.descripcion, S.[weight], S.TMO 
	From Section S 
	inner join Speech Sp
	on Sp.PK_Speech=S.PK_Speech
	Where (PK_Section=@pPK_Section) and (S.estado=1) and (Sp.estado=1)
End
GO
/****** Object:  StoredProcedure [dbo].[uspSectionDrop]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCedure [dbo].[uspSectionDrop]
(
	@pSectionName		VarChar(300)
)
as
Begin	
	Select PK_Section,name 'SectionName'
	From Section
	Where name like '%'+@pSectionName+'%'
	and estado=1
End
GO
/****** Object:  StoredProcedure [dbo].[uspSectionInsUpd]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCedure [dbo].[uspSectionInsUpd]
(
	@pPK_Section		Int,
	@pName				VarChar(300),
	@pPK_Speech			Int,
	@pdescription		varchar(max),
	@pWeight			Numeric(5,2),
	@pTMO				decimal(5,2),
	@pOutVal			Int OutPut
)
As
Begin 
	declare @SumPeso numeric(5,2)
	declare @TablaSection  table
	(
	Pk_Section int,
	name varchar(200),
	PK_Speech  int,
	[weight] numeric(5,2),
	estado int
	)

	If Exists (Select name
			   From Section
			   Where PK_Section=@pPK_Section)
		Begin
			Begin
				declare @pksection int, @name varchar(300),@descripcion varchar(max),
						@pkspeech int, @weight Numeric(5,2), @tmo Numeric(5,2),@CreatedDate datetime
				select @pksection=PK_Section, @name=name, @pkspeech=PK_Speech,
						@descripcion=descripcion, @weight=weight, @tmo=TMO,@CreatedDate=CreateDate from Section
				
				insert into Section_Detail(PK_Section,name,PK_Speech,descripcion,weight,TMO,
						CreateDate,UpdateDate) values(@pksection,@name,@pkspeech,@descripcion,
						@weight,@tmo,@CreatedDate,GETDATE())
			End

			Begin

				insert into @TablaSection
				select Pk_Section,name,PK_Speech,[weight],estado from Section where pk_speech = @pPK_Speech and estado = 1
				update @TablaSection
				set [weight] = @pWeight 
				where Pk_Section = @pPK_Section

				set @SumPeso = (select sum([weight]) from @TablaSection where pk_speech = @pPK_Speech and estado = 1)

				if @SumPeso <= 100
				begin 
					Update Section
						Set name=@pName,PK_Speech=@pPK_Speech, descripcion=@pdescription, 
						[weight]=@pWeight, TMO=@pTMO,UpdateDate=GETDATE(),CreateDate=GETDATE()
					Where PK_Section=@pPK_Section
					
				end 

				Set @pOutVal=2

			End
		End
	Else 
		Begin

			insert into @TablaSection
			select Pk_Section,name,PK_Speech,[weight],estado from Section where pk_speech = @pPK_Speech and estado = 1
			insert into @TablaSection(Pk_Section,name,PK_Speech,[weight],estado)values
			(@pPK_Section,@pName,@pPK_Speech,@pWeight,1)

			set @SumPeso = (select sum([weight]) from @TablaSection where pk_speech = @pPK_Speech and estado = 1)
			
			if @SumPeso <= 100
			begin 
				Insert Into Section(name,PK_Speech,descripcion,[weight],TMO) Values (@pName,@pPK_Speech,@pdescription,@pWeight,@pTMO)
			end 
			Set @pOutVal=1

		End
End
GO
/****** Object:  StoredProcedure [dbo].[uspSectionLst]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCedure [dbo].[uspSectionLst] 
(
	@pPKSpeech			Int,
	@pName				VarChar(300)
)
As
Begin
	Select Sp.PK_Speech, Se.PK_Section,Se.name 'SectionName',Sp.name 'SpeechName',
			Se.descripcion,Se.[weight],Se.TMO
	From Section Se
	Inner Join Speech Sp On Se.PK_Speech=Sp.PK_Speech	
	Where (Se.name like '%'+@pName+'%') And (Se.PK_Speech= @pPKSpeech Or @pPKSpeech=0)and (Se.estado=1)
End
GO
/****** Object:  StoredProcedure [dbo].[uspSpeechById]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

create PROCedure [dbo].[uspSpeechById]
(
	@pPK_Speech		Int
)
As
Begin
	Select s.PK_Speech,s.name,s.description,s.FK_Business
	From Speech s inner join Business b
	on s.FK_business = b.PK_Business
	Where s.PK_Speech=@pPK_Speech and s.estado=1
End
GO
/****** Object:  StoredProcedure [dbo].[uspSpeechDel]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[uspSpeechDel]
(
	@pPK_Speech		Int
)
As
Begin
	declare @pkspeech int ,@name varchar(350),@descripcion varchar(2000),
				@pkbusiness int, @CreatedDate datetime
				select @pkspeech = PK_Speech, @name= name, @descripcion=[description],
				@pkbusiness=Fk_business,@CreatedDate=CreatedDate from Speech			

	Begin
		Update Speech set estado=0, DeleteDate=GETDATE()
		Where PK_Speech=@pPK_Speech
	end

	Begin
		update Business set estado = 1
		where PK_Business = @pkbusiness
	end
End
GO
/****** Object:  StoredProcedure [dbo].[uspSpeechInsUpd]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCedure [dbo].[uspSpeechInsUpd]
(
	@pPK_Speech		Int,
	@pName			VarChar(350),
	@pDescription	VarChar(2000),
	@pPK_business	Int,
	@pOutVal		Int OutPut
)
As
Begin
	If Exists(Select name
			  From Speech
			  Where PK_Speech=@pPK_Speech)
		Begin 
			Begin
				declare @pkspeech int ,@name varchar(350),@descripcion varchar(2000),
				@pkbusiness int, @CreatedDate datetime
				select @pkspeech = PK_Speech, @name= name, @descripcion=[description],
				@pkbusiness=Fk_business,@CreatedDate=CreatedDate from Speech
				
				insert Speech_Detalle(PkSpeech,name,descripcion,fk_business,CreatedDate,UpdateDate) Values (@pkspeech,@name,@descripcion,@pkbusiness,@CreatedDate,GETDATE())
			End
			
			Begin

				update Business set estado=1
				where PK_Business=@pkbusiness
				
				Update Speech
					Set name=@pName, [description]=@pDescription, Fk_business=@pPK_business,CreatedDate=GETDATE(),UpdateDate=GETDATE()
				Where PK_Speech=@pPK_Speech
				Set @pOutVal=2

				--update Business set estado=0
				--where PK_Business=@pPK_business

			End
		End
	Else
		Begin
			Insert Into Speech (name,[description],Fk_business)Values (@pName,@pDescription,@pPK_business)
			Set @pOutVal=1
		End

		--Begin 
		--	update Business set estado=0
		--		where PK_Business=@pPK_business
		--End
End
GO
/****** Object:  StoredProcedure [dbo].[uspSpeechLst]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[uspSpeechLst]
(
	@pName			VarChar(350),
	@pDescription	VarChar(2000),
	@pFk_Business	Int
)
As 
Begin
	Select S.name 'SpeechName',S.PK_Speech, S.description,SO.name--,Sec.PK_Section
	From Speech S Inner Join Business SO 
	On S.FK_business=SO.PK_Business 
	Where ((S.name like '%'+@pName+'%' or @pName='') And
		  (S.[description] like '%'+@pDescription+'%' or @pDescription='') And
		  (S.FK_business=@pFk_Business  or @pFk_Business=0)and (S.estado=1 ) )  

	Select Sec.PK_Section,Sec.name 'SectionName' from Speech Sp
	inner join Section Sec
	on Sp.PK_Speech=Sec.PK_Speech
	where Sec.estado=1
End
GO
/****** Object:  StoredProcedure [dbo].[uspSubOfficeLst2]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure  [dbo].[uspSubOfficeLst2]
(
	@pnameSubOffice  	VarChar(1000),
	@pPK_Office	Int
)
As
Begin
	Select PK_SubOffice,nameSubOffice,B.nameOffice
	From SubOffice	A
	Inner Join Office B On A.PK_Office=B.PK_Office
	Where (nameSubOffice like '%'+@pnameSubOffice+'%' Or @pnameSubOffice='') And	
		  
		  (A.PK_Office=@pPK_Office or @pPK_Office=0)	and A.estado=1	  
End
GO
/****** Object:  StoredProcedure [dbo].[uspWhiteListar]    Script Date: 12/02/2020 20:00:03 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create PROCedure [dbo].[uspWhiteListar]
as
	select W.[PK_word],W.[word],W.[Porcentaje],E.[Name] from whiteList W
	inner join Enterprise E
	on W.EnterPrise = E.PK_Enterprise
	where W.estado=1 and E.estado=1
GO
