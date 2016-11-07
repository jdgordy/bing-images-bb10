/*
 * HttpDataSource.hpp
 *
 *  Created on: Oct 4, 2013
 *      Author: jgordy
 */

#ifndef HTTPDATASOURCE_HPP_
#define HTTPDATASOURCE_HPP_

#include <bb/data/DataAccessErrorType>
#include <bb/cascades/Image>
#include <QtCore/QObject>
#include <QtCore/QUrl>
#include <QtCore/QMutex>

// Forward declarations
class QNetworkAccessManager;
class QNetworkReply;

//
// HttpDataSource
//
class HttpDataSource : public QObject
{
    Q_OBJECT

    // Source URL
    Q_PROPERTY(QUrl source READ source WRITE setSource NOTIFY sourceChanged FINAL);

    // Target URL
    Q_PROPERTY(QUrl target READ target WRITE setTarget NOTIFY targetChanged FINAL);

public:

    // Constructor / destructor
    HttpDataSource(QObject* pParent = NULL);
    virtual ~HttpDataSource();

    // Property accessor methods
    QUrl source() const;
    Q_SLOT void setSource(const QUrl& source);

    // Property accessor methods
    QUrl target() const;
    Q_SLOT void setTarget(const QUrl& source);

    // Begin loading data
    Q_SLOT void load();

    // Abort loading data
    Q_SLOT void abort();

Q_SIGNALS:

    // Emitted on source change
    void sourceChanged(QUrl source);

    // Emitted on target change
    void targetChanged(QUrl source);

	// Emitted on data loading completion
	void dataLoaded(const QVariant& data, const QString& mimeType);

	// Emitted on image loading completion
	void imageLoaded(const bb::cascades::Image& image, const QString& mimeType);

	// Emitted on target updated
	void targetUpdated();

	// Emitted on error
	void error(bb::data::DataAccessErrorType::Type errorType, const QString& errorMessage);
	void error(int errorType, const QString& errorMessage);

protected Q_SLOTS:

	// Handler for transaction completion
	void handleFinished();

protected:

    // Property values
    QUrl m_source;
    QUrl m_target;

    // Network access manager
    QMutex                  m_mutex;
    QNetworkAccessManager*  m_pManager;
    QNetworkReply*          m_pReply;
    bool                    m_bTransactionPending;
};

#endif /* HTTPDATASOURCE_HPP_ */
